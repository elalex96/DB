-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12/02/2018>
-- Description:	<Consultar preguntas>
-- =============================================
CREATE procedure ME_ConsultaPreguntas
@IdSeccion int 
as
begin
	SELECT  p.IdPregunta, p.IdSeccion as Seccion, tr.Nombre as Respuesta, Pregunta,  Ponderacion, AplicaPersonaMoral, RequiereDocumento, p.IdTipoRespuesta
		FROM ME_Preguntas p
			INNER JOIN ME_TiposRespuesta tr on tr.IdTipoRespuesta= p.IdTipoRespuesta
		WHERE p.IdSeccion= @IdSeccion
			AND (p.Activo = 1 OR p.Activo IS NULL);
end
