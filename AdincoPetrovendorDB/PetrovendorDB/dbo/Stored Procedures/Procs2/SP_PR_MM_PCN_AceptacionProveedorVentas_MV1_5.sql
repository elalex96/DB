

-- =============================================
-- Author:		Daniel AC
-- Update date: 17-04-18
-- Description:	Actualice IdMaterial a IdMaterialVendedor
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 24/09/2019
-- Description:	Redonde a 3 digitos del PCN segun la SE
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 27/08/2020
-- Description:	se agrego una validacion para mostrar el codigo de la secretaria de economia cuando el cliente es jaguar
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
                --SUBSTRING(LTRIM(ISNULL(ROUND(APD.PCN,4),0)),1,CHARINDEX('.',LTRIM(ISNULL(ROUND(APD.PCN,4),''))) + 3) AS PCN,
				ROUND(ISNULL(APD.PCN,0),3) AS PCN,
                TM.TipoMonedaCorto              AS Moneda
        FROM
                MM_AceptacionPedidoDetalle AS APD
            INNER JOIN
                MM_AceptacionPedido        AS A
                    ON A.IdAceptacionPedido = APD.IdAceptacionPedido
            INNER JOIN
                MM_PedidoDetalle           AS PD
                    ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
            INNER JOIN
                MM_Pedido                  AS P
                    ON P.IdPedido = A.IdPedido
            INNER JOIN
                MM_PeticionOferta          AS PO
                    ON PO.IdPeticionOferta = P.IdPeticionOferta
            INNER JOIN
                MM_PeticionOfertaDetalle   AS POD
                    ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
            INNER JOIN
                PV_TipoMoneda              AS TM
                    ON TM.IdMoneda = PD.IdMoneda
			LEFT JOIN dbo.MM_Material AS M
				ON M.IdMaterial = PD.IdMaterialVendedor
			LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
				ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
			LEFT JOIN dbo.MM_Material AS MSP
				ON MSP.IdMaterial = SPD.IdMaterial
			LEFT JOIN dbo.CO_CONTRATOSJAGUAR AS PJ
				ON PJ.IdOperadora = P.IdProveedorCompras
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