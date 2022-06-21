-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/06/2022
-- Description:	Validacion de alias en marcos legales
-- =============================================
CREATE PROCEDURE SP_EN_ValidarAliasMarcoLegal
	-- Add the parameters for the stored procedure here
	@Alias VARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @EXISTE BIT = 0;

	SELECT
		@EXISTE = CASE	
					WHEN Alias != '' THEN 1
					ELSE 0
				END
	FROM EN_MarcoLegal
	WHERE Alias = @Alias;

	SELECT @EXISTE AS EXISTE;

END
GO
