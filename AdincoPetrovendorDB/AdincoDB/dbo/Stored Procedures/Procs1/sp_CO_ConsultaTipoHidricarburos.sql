-- =============================================
-- Author:		Miguel Gomez
-- Create date: 2017.01.01
-- Description:	Lista todos los tipos de hidrocarburos
-- =============================================
CREATE PROCEDURE sp_CO_ConsultaTipoHidricarburos 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        IdTipoHidrocarburo, TipoHidrocarburo, Hidrocarburo
FROM            CO_TipoHidrocarburo
END
