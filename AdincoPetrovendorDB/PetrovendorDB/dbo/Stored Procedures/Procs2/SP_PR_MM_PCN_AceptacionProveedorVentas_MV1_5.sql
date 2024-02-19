USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_PCN_AceptacionProveedorVentas_MV1_5'
)
    DROP PROCEDURE SP_PR_MM_PCN_AceptacionProveedorVentas_MV1_5; 
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_PCN_AceptacionProveedorVentas_MV1_5]    Script Date: 16/02/2024 04:32:35 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Daniel AC
-- Update date: 17-04-18
-- Description: Actualice IdMaterial a IdMaterialVendedor
-- =============================================
-- Author:      Alexander Gomez
-- Update date: 24/09/2019
-- Description: Redonde a 3 digitos del PCN segun la SE
-- =============================================
-- Author:      Alexander Gomez
-- Update date: 27/08/2020
-- Description: se agrego una validacion para mostrar el codigo de la secretaria de economia cuando el cliente es jaguar
-- =============================================
-- Author:		Luis David
-- Create date: 04/11/2021
-- Description:	Reacomodo de tablas para optimización
-- =============================================
-- Author:      Alexander Gomez
-- Update date: 17/11/2021
-- Description: se recorta a 3 digitos del PCN segun la SE 
-- =============================================
-- =============================================
-- Author:      Alexander Gomez
-- Update date: 19/05/2022
-- Description: se recorta a 3 digitos sin redondear del PCN segun la SE y se optimiza
-- =============================================
-- =============================================  
-- Author:  Daniel AC
-- Create date: 16/02/2024
-- Description: Regresar el formato de PCN en 3 decimales 0.000 --> 0.600
-- =============================================  
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionProveedorVentas_MV1_5] 
    -- Add the parameters for the stored procedure here
    @IdProveedor        INT,
    @IdAceptacionPedido INT,
    @IdContrato         INT = NULL,
    @IdUsuario          INT = NULL,
    @FechaRegistro      DATETIME = NULL
AS
    BEGIN
        SET NOCOUNT ON;

	    --> PCN: Primero se corta a 3 decimales para evitar redondeo, luego se pasa a decimal con 3 decimales, para luego retornarlo como string con formato 3 decimales #.###

        SELECT
                APD.IdAceptacionPedidoDetalle,
                PD.IdMaterialVendedor           AS IdMaterial,
                --VALIDACION DE CLIENTE JAGUAR
                CASE 
                    WHEN PJ.ID IS NOT NULL THEN (POD.MaterialCotizadoTextoC + ' Código S.E.: ' +  MSP.Marca)                                       
 
                    ELSE POD.MaterialCotizadoTextoC
                END AS DescripcionCorta,
                POD.UnidadProveedor             AS Unidad,
                APD.Cantidad,
                APD.Excedente,
                PD.PrecioUnitario,
				FORMAT(CAST(CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar),1,5) AS nvarchar) AS decimal(12,3)),'0.000') AS PCN,
                TM.TipoMonedaCorto              AS Moneda
        FROM
                MM_AceptacionPedidoDetalle AS APD
            JOIN
                MM_AceptacionPedido        AS A
                    ON APD.IdAceptacionPedido = A.IdAceptacionPedido
					AND A.IdAceptacionPedido = @IdAceptacionPedido
            JOIN
                MM_PedidoDetalle           AS PD
                    ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
            JOIN
                MM_Pedido                  AS P
                    ON A.IdPedido = P.IdPedido
						AND P.IdSubcontratista = @IdProveedor
            JOIN
                MM_PeticionOferta          AS PO
                    ON P.IdPeticionOferta = PO.IdPeticionOferta
            JOIN
                MM_PeticionOfertaDetalle   AS POD
                    ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
            JOIN PV_TipoMoneda              AS TM
                    ON PD.IdMoneda = TM.IdMoneda
            JOIN dbo.MM_Material AS M
                ON PD.IdMaterialVendedor = M.IdMaterial
            JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
                ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
            JOIN dbo.MM_Material AS MSP
                ON SPD.IdMaterial = MSP.IdMaterial
			LEFT JOIN dbo.CO_CONTRATOSJAGUAR AS PJ
                ON P.IdProveedorCompras = PJ.IdOperadora
        GROUP BY
          APD.IdAceptacionPedidoDetalle,
                PD.IdMaterialVendedor,
                POD.MaterialCotizadoTextoC,
                POD.UnidadProveedor,
                APD.Cantidad,
                APD.Excedente,
                PD.PrecioUnitario,
                APD.PCN,
                TM.TipoMonedaCorto,
                M.DescripcionCorta,
                MSP.Marca,
                PJ.ID
    END;