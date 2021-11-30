USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PV_ConsultarDominio]    Script Date: 26/11/2021 01:58:10 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_PV_ConsultarDominio] 
	-- Add the parameters for the stored procedure here
	@IDENTIFICADOR INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Url FROM TA_Dominios (NOLOCK) WHERE Identificador = @IDENTIFICADOR AND Activo = 1 AND IdServidor = @IDENTIFICADOR

END
