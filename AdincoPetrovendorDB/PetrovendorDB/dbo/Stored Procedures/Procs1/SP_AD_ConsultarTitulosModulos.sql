-- =============================================
-- Author:		<Pedro Acuña>
-- Modified date: <15-01-2018>
-- Description:	<Se modifica ya que el id primario se estaba repitiendo, ademas se agrega a que aplicacion esta apuntando>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultarTitulosModulos]
-- Add the parameters for the stored procedure here
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT TM.IdTitulosModulo,
           T.IdTitulo,
           T.NombreTitulo,
           T.NombreSubtitulo,
           M.URL_MODULO,
           T.ModificadoEl,
           (CASE
                WHEN T.IdIdioma = 1 THEN
                    'ESPAÑOL'
                ELSE
                    'INGLES'
            END
           ) AS IDIOMA,
           CASE
               WHEN M.Aplicacion = 0 THEN
                   'Petrovendor'
               ELSE
                   CASE
                       WHEN M.Aplicacion = 1 THEN
                           'Procura'
                   END
           END AS Aplicacion
    FROM dbo.Titulos AS T
        INNER JOIN dbo.TituloModulo AS TM
            ON TM.IdTitulo = T.IdTitulo
        INNER JOIN dbo.Modulo AS M
            ON M.IdModulo = TM.IdModulo

END
