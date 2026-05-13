-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-07-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Update date: 09-01-2018
-- Description:	Agregue conversión de moneda
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_TablaComparativa_MV1_5]  
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	/*--------------------   parametros contrato  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 
  /*----------------------------------------*/

--exec SP_PR_MM_TablaComparativa 11176
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT 
				PO.IdPeticionOferta,
                SP.IdSolicitudPedido,
                MS.IdMaterial,
				MS.DescripcionCorta AS MaterialCotizadoTextoC,
                ISNULL(POD.ComentariosComprador,''),
                POD.NoMaterialesRequeridos,
                P.RazonSocial+' '+P.RegimenCapital AS Razonsocial,
                CASE
                    WHEN CONVERT(NVARCHAR(15), PO.Cotizado) = 1
                    THEN 'COTIZADO'
                    ELSE 'NO COTIZADO'
                END AS Cotizado,
				CASE WHEN (POD.IdMoneda <> 2 AND POD.IdMoneda IS NOT NULL) THEN --ES DIREFERENTE DE MONEDA 2 DLS 
					CAST(ROUND(ISNULL(POD.PrecioUnitario,0)/ISNULL([dbo].[GetTipoCambioActualScalar](POD.IdMoneda, GETDATE()),0),2 )AS DECIMAL(15, 2)) 
				ELSE
					CAST(ISNULL(POD.PrecioUnitario, 0) AS DECIMAL(15, 2))   ---ES MONEDA DLS
				END 
                AS PrecioUnitario
         FROM MM_PeticionOferta PO
              INNER JOIN S_Proveedor P ON P.IdProveedor = PO.IdSubcontratista
              INNER JOIN MM_SolicitudPedido SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
              INNER JOIN MM_PeticionOfertaDetalle POD ON PO.IdPeticionOferta = POD.IdPeticionOferta
              LEFT JOIN  dbo.MM_Material MS ON MS.IdMaterial = POD.IdMaterial
         WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
         ORDER BY P.RazonSocial DESC;
     END;
