USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_PCN_AceptacionProveedorVentas_MV1_5]    Script Date: 18/05/2022 04:50:50 p. m. ******/
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
-- Author:  Alexander Gomez  
-- Create date: 18/05/2022
-- Description: truncado a 3 digitos sin redondeo del PCN segun la SE (Modificacion)
-- =============================================
ALTER PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionProveedorVentas_MV1_5] 
    -- Add the parameters for the stored procedure here
    @IdProveedor        INT,
    @IdAceptacionPedido INT,
    @IdContrato         INT = NULL,
    @IdUsuario          INT = NULL,
    @FechaRegistro      DATETIME = NULL
AS
    BEGIN
        SET NOCOUNT ON;
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
				CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar),1,5) AS nvarchar) AS PCN,
                TM.TipoMonedaCorto              AS Moneda
        FROM
                MM_AceptacionPedidoDetalle AS APD
            INNER JOIN
                MM_AceptacionPedido        AS A
                    ON APD.IdAceptacionPedido = A.IdAceptacionPedido
            INNER JOIN
                MM_PedidoDetalle           AS PD
                    ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
            INNER JOIN
                MM_Pedido                  AS P
                    ON A.IdPedido = P.IdPedido
            INNER JOIN
                MM_PeticionOferta          AS PO
                    ON P.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN
                MM_PeticionOfertaDetalle   AS POD
                    ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
            INNER JOIN PV_TipoMoneda              AS TM
                    ON PD.IdMoneda = TM.IdMoneda
            LEFT JOIN dbo.MM_Material AS M
                ON PD.IdMaterialVendedor = M.IdMaterial
            LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
                ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
            LEFT JOIN dbo.MM_Material AS MSP
                ON SPD.IdMaterial = MSP.IdMaterial
         LEFT JOIN dbo.CO_CONTRATOSJAGUAR AS PJ
                ON P.IdProveedorCompras = PJ.IdOperadora
        WHERE
                P.IdSubcontratista = @IdProveedor
                AND A.IdAceptacionPedido = @IdAceptacionPedido
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