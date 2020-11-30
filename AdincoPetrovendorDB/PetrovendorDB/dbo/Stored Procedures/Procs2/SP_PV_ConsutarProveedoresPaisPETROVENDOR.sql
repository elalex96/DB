
CREATE PROCEDURE [dbo].[SP_PV_ConsutarProveedoresPaisPETROVENDOR]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT id,Pais AS PaisNombre
    from Petrovendor.dbo.PV_PaisRepublica
	

END


