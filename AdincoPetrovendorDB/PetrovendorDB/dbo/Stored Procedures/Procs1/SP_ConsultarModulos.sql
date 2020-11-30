-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se dividio para saber si el modulo pertenece a procura o petrovendor >
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarModulos]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT IdModulo,
           NombreModulo,
           ISNULL(StringModuloId, 'Sin identificador') StringModuloId,
           URL_MODULO,
           CASE WHEN Aplicacion = 1 THEN 'Procura' ELSE 'Petrovendor' END AS Aplicacion
    FROM Modulo
    ORDER BY NombreModulo

END
