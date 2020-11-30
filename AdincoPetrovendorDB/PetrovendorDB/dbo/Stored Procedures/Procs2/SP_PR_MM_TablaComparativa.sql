-- =============================================
-- Author:		Manuel Cruz
-- Create date: 17-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_TablaComparativa]
	-- Add the parameters for the stored procedure here
@IdSolicitudPedido INT

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
                POD.IdMaterial,
				MS.TextoCorto,
                MS.IdSubFamilia,
                POD.ComentariosComprador,
                POD.NoMaterialesRequeridos,
                P.RazonSocial+' '+P.RegimenCapital AS Razonsocial,
                CASE
                    WHEN CONVERT(NVARCHAR(15), PO.Cotizado) = 1
                    THEN 'COTIZADO'
                    ELSE 'NO COTIZADO'
                END AS Cotizado,
                ISNULL(POD.PrecioUnitario, 0) AS PrecioUnitario
         FROM MM_PeticionOferta PO
              INNER JOIN S_Proveedor P ON P.IdProveedor = PO.IdSubcontratista
              INNER JOIN MM_SolicitudPedido SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
              INNER JOIN MM_PeticionOfertaDetalle POD ON PO.IdPeticionOferta = POD.IdPeticionOferta
              INNER JOIN MM_Maestro MS ON MS.IdMaestro = POD.IdMaterial
         WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
         ORDER BY P.RazonSocial DESC;
     END;
