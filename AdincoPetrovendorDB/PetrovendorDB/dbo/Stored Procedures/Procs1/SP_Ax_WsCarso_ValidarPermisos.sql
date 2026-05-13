CREATE PROCEDURE [dbo].[SP_Ax_WsCarso_ValidarPermisos]
    -- Add the parameters for the stored procedure here
    @DataAreaID NVARCHAR(500)


AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	SELECT 	
	ISNULL(Activo,1) AS Activo
	FROM  dbo.AX_ComparativaEmpresa	
	WHERE DataAreaID=@DataAreaID	

END;
