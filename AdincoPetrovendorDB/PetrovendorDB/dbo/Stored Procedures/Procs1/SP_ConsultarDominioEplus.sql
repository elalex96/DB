-- =============================================
-- Author:      <Abel Rivera>
-- Create date: <12/02/20>
-- Description: <Consulta la url del dominio de eplus>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDominioEplus]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SELECT Url FROM dbo.TA_Dominios WHERE IdDominio = 3 AND Activo = 1
END