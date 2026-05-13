-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2017
-- Description:	Add Default Columns to Table
-- =============================================
CREATE PROCEDURE [dbo].[sp_UT_AddDefaultColumns] 
	-- Add the parameters for the stored procedure here
	@TableName nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	ALTER TABLE CO_PuntoMedicion ADD 	[CreadoPor] [int] NULL,
	[CreadoEl] [datetime] NULL,
	[ModificadoPor] [int] NULL,
	[ModificadoEl] [datetime] NULL,
	[Activo] [bit] NULL ;  
END
