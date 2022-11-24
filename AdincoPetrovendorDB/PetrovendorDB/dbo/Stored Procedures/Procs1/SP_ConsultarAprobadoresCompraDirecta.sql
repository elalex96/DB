-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/05/2022
-- Description:	 Se descartan en la aprobacion los usuarios eliminados
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarAprobadoresCompraDirecta]  
@IdOperacion int,
@IdTipoOperacion int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT 
		TT.IdAprobador, 
		TT.NoSecuencia, 
		U.Nombre as Aprobadores, 
		TT.IdEstatus, 
		TE.Nombre, 
		TT.Comentario, 
		TT.FechaCambioEstatus
	FROM TA_Estatus TE
	INNER JOIN TA_Tarea TT 	
		ON TE.IdEstatus = TT.IdEstatus	
	INNER JOIN S_Usuario U	
		ON U.IdUsuario = TT.IdAprobador
		AND U.Activo = 1 
		AND ISNULL(U.IsEliminado,0) = 0
	INNER JOIN TA_Operacion TAO 
		ON TT.IdOperacion = TAO.IdOperacion
	WHERE   TAO.IdTipoOperacion = @IdTipoOperacion AND TT.IdOperacion= @IdOperacion
	ORDER BY TT.NoSecuencia ASC

	--- TT.IdEstatus = 2
END
