USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[ME_ConsultaComboOpciones]    Script Date: 26/11/2021 01:53:50 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[ME_ConsultaComboOpciones]
	@IdPregunta int 
as
begin
	SELECT Respuesta, IdRespuestasOpciones
		FROM dbo.ME_RespuestasOpciones (NOLOCK)
		WHERE IdPregunta = @IdPregunta
END

