-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/07/2020>
-- Description:	<Consulta de historial de aprobacion de los documentos solicitados al proveedor>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_ConsultaFlujoAprobacionDocumentos] --4
	-- Add the parameters for the stored procedure here
	@IdAceptacionDocumento INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		T.IdTarea,
		T.NoSecuencia,
		T.FechaCambioEstatus,
		US.Nombre AS Aprobador,
		EST.Nombre AS Estatus,
		ISNULL(T.Comentario,'') AS Comentario
	FROM dbo.TA_Tarea AS T
		LEFT JOIN dbo.TA_Operacion AS OP
			ON OP.IdOperacion = T.IdOperacion
			AND OP.IdTipoOperacion = 18
		LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP
			ON ADP.IdAceptacionDocumento = OP.IdDocumento
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = T.IdAprobador
		LEFT JOIN dbo.TA_Estatus AS EST
			ON EST.IdEstatus = T.IdEstatus
	WHERE ADP.IdAceptacionDocumento = @IdAceptacionDocumento
		AND T.Activo = 1
	GROUP BY T.NoSecuencia,
             T.FechaCambioEstatus,
             US.Nombre,
             EST.Nombre,
			 T.IdTarea,
			 T.Comentario
	ORDER BY T.IdTarea ASC;
	
END
