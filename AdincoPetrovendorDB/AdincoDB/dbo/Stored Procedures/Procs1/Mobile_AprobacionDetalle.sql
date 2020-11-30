--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [dbo].[Mobile_AprobacionDetalle]
    @IdTareaOrigen AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
    SELECT TOP 1
	AM.IdTareaOrigen
	,TIP.NombreOperacion
	, CASE WHEN AM.IdTipoAprobacion = 9 THEN AM.IdPedido 
	ELSE AM.IdDocumento END AS IdDocumento
	,IdTipoAprobacion
	,CONVERT(nvarchar(10),FechaCreacion, 105)AS 'FechaRequi'
	,ComentarioAprobacion AS 'Descripcion'
	,ComentarioDocumento AS 'Comentario'
	,NoVersion
	,CASE WHEN AM.idtipoaprobacion =9
	THEN
		'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
	WHEN  AM.idtipoaprobacion =2
	THEN
		'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
	END
    AS 'URI'
	FROM dbo.AM_Aprobacion AS AM
	JOIN Petrovendor.dbo.TA_TipoOperacion AS TIP
	ON AM.IdTipoAprobacion = TIP.IdTipoOperacion 
	WHERE IdTareaOrigen = @IdTareaOrigen

