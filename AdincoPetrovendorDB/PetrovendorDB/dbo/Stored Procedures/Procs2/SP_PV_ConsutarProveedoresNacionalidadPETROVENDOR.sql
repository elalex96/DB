
CREATE PROCEDURE [dbo].[SP_PV_ConsutarProveedoresNacionalidadPETROVENDOR]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 SELECT n.IdNacionalidad, n.Nacionalidad
    from Petrovendor.dbo.S_Nacionalidad n
	

END


