-- =============================================
-- Author:		<Pedro, Acuña>
-- Create date: <15/01/2018>
-- Description:	<Se modifica ya que se cambio la llave primaria a actualizar>
-- =============================================
CREATE PROCEDURE SP_AD_ActualizarTituloModulo
    -- Add the parameters for the stored procedure here
    @IdTitulosModulo INT,
    @NombreTitulo NVARCHAR(MAX),
    @NombreSubtitulo NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;



    -- Insert statements for procedure here
    UPDATE T
    SET T.NombreTitulo = @NombreTitulo,
        T.NombreSubtitulo = @NombreSubtitulo,
        T.ModificadoEl = GETDATE()
    FROM Titulos T
        INNER JOIN dbo.TituloModulo AS TM
            ON TM.IdTitulo = T.IdTitulo
    WHERE TM.IdTitulosModulo = @IdTitulosModulo

END
