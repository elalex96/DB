-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CP_ConsultaParametroRegaliaLic 
	-- Add the parameters for the stored procedure here
	@Mes date 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdParametroRegalias, Anio, An, Bn, Cn, Dn, En, Fn, Gn, Hn
FROM            CP_ParametroRegalia
WHERE        (YEAR(@mes) = Anio)
END
