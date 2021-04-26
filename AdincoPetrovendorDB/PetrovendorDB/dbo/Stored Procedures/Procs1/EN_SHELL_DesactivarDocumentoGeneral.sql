USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_SHELL_DesactivarDocumentoGeneral'
)
    DROP PROCEDURE EN_SHELL_DesactivarDocumentoGeneral;
GO 

/****** Object:  StoredProcedure [dbo].[EN_SHELL_GuardarDocumentoGeneral]    Script Date: 26/04/2021 1:37:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EN_SHELL_DesactivarDocumentoGeneral]    
	@ContratoId INT,
	@UsuarioId INT,
	@DocumentoId INT
AS
BEGIN
		
		UPDATE EN_DocumentoGeneral
		SET Activo=0,
		ModificadoEl=GETDATE(),
		ModificadoPor=@UsuarioId
		WHERE DocumentoId=@DocumentoId
		AND ContratoId=@ContratoId

		SELECT 'SUCCESS',
		DocumentoId
		FROM EN_DocumentoGeneral
		WHERE DocumentoId=@DocumentoId
		AND ContratoId=@ContratoId

 END
