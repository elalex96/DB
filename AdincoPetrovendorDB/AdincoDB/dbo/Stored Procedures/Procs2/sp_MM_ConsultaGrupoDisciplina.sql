-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_MM_ConsultaGrupoDisciplina 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdGrupoDisciplina, MaterialGrupo
FROM            MM_MaterialGrupoDisciplina

where Activo = 1 
END
