USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_InsertarAdjunto'
)
    DROP PROCEDURE sp_SC_InsertarAdjunto; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_InsertarAdjunto]    Script Date: 10/07/2023 11:02:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================
CREATE Proc [dbo].[sp_SC_InsertarAdjunto]
	@pIdAdjunto			int out,
	@pIdSubContrato		int,
	@pDescripcion		varchar(250),
	@pCreadoPor			int,
	@pAWSDocumentoId	int

As
begin
	SET NOCOUNT ON;
	SELECT @pIdAdjunto = isnull(max(IdAdjunto),0) + 1
	FROM SC_Adjunto (NOLOCK)

	INSERT INTO SC_Adjunto(	IdAdjunto,		
	IdSubcontrato,		
	Descripcion,
	Extension,	
	CreadoPor,		
	CreadoEl,	
	AWSDocumentoId)
	select					
	@pIdAdjunto,	
	@pIdSubContrato,	
	@pDescripcion,
	'',	
	@pCreadoPor,	
	getdate(),	
	@pAWSDocumentoId

end