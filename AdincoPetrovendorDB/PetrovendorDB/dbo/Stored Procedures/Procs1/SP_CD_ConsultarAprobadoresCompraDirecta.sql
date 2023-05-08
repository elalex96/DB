-- =============================================
-- Author:		Daniel AC
-- Create date: 16/11/2017
-- Description:	Consultar aprobadores de compra directa
-- =============================================
CREATE PROCEDURE [dbo].[SP_CD_ConsultarAprobadoresCompraDirecta] 
@IdFactura int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT  TT.IdFirma AS FirmaElectronica,
			TT.IdAprobador, 
			TT.NoSecuencia, 
			U.Nombre as Aprobadores, 
			TT.IdEstatus, 
			TE.Nombre, 
			TT.Comentario, 
			TT.FechaCambioEstatus
	FROM TA_Estatus TE
	INNER JOIN TA_Tarea TT 	ON TE.IdEstatus = TT.IdEstatus	
	INNER JOIN S_Usuario U	ON U.IdUsuario = TT.IdAprobador
	INNER JOIN TA_Operacion TAO ON TT.IdOperacion = TAO.IdOperacion
	INNER JOIN CO_Registro R ON R.IdFactura = TAO.IdDocumento
	INNER JOIN FI_Factura F ON F.IdFactura = TAO.IdDocumento
	WHERE  TAO.IdDocumento = @IdFactura   AND TAO.IdTipoOperacion = 14 	 
	ORDER BY TT.NoSecuencia ASC
	 
END

