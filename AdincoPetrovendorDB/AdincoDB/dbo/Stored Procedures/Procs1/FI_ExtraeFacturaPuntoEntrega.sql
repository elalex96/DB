-- =============================================
-- Author:	Reyna Olvera
-- Create date:13/04/2018
-- Description:	Extrae las facturas y nomre de puntos de entrega para saber cuales son la que ya tienen asignadas puntos de entrega
-- =============================================
CREATE PROCEDURE [dbo].[FI_ExtraeFacturaPuntoEntrega]
	-- Add the parameters for the stored procedure here
	@idcontrato int,
	@idUsuario int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	      SET LANGUAGE spanish;
    -- Insert statements for procedure here
	Select idFacturaPuntoEntrega,F.idFactura,folio,PE.Nombre,  CP.Nombre,  
	CONCAT(datename(month, MesReporte), ' ', YEAR(MesReporte)) AS MesReporte

				 from FI_FacturaPuntoEntrega FP
				JOIN CO_PuntosdeEntrega PE on FP.PuntoEntregaId=Pe.PuntoEntregaID
				JOIN FI_Factura F on FP.idFactura =f.idFactura
				JOIN [CO_ClasificacionProductoNominacion] CP on FP.ProductoId =CP.ProductoNominacionId
				Where idContrato=@idcontrato
order by  FP.mesreporte desc
END