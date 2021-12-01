USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[ME_ConsultaPreguntas]    Script Date: 26/11/2021 01:53:21 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12/02/2018>
-- Description:	<Consultar preguntas>
-- =============================================
ALTER procedure [dbo].[ME_ConsultaPreguntas]
@IdSeccion int 
as
begin
	SELECT  p.IdPregunta, p.IdSeccion as Seccion, tr.Nombre as Respuesta, Pregunta,  Ponderacion, AplicaPersonaMoral, RequiereDocumento, p.IdTipoRespuesta
		FROM ME_Preguntas p (NOLOCK)
			INNER JOIN ME_TiposRespuesta tr (NOLOCK) on tr.IdTipoRespuesta= p.IdTipoRespuesta 
		WHERE p.IdSeccion= @IdSeccion
			AND (p.Activo = 1 OR p.Activo IS NULL);
end
