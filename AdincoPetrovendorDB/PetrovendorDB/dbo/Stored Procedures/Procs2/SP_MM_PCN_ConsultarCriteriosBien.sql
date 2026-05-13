-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Consultar criterios del bien
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_ConsultarCriteriosBien]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT 
	IdCriterio,
	Nombre
	FROM dbo.MM_PCN_CriterioBien 
	WHERE Activo=1
	ORDER BY IdCriterio ASC
	

END;

