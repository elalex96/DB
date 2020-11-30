-- =============================================
-- Author:		Daniel AC
-- Create date: 15/10/2018
-- Description:	AGREGAR DETALLE DE UNA COMPARATIVA
-- =============================================
CREATE PROCEDURE [dbo].[SP_Ax_WsCarso_DesactivarPosicionesComparativa]
    -- Add the parameters for the stored procedure here
    @DataAreaID NVARCHAR(500),	
	@IdComparativa NVARCHAR(500),
	@IDPosicionVigentes NVARCHAR(MAX)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	CREATE TABLE  #POSICIONES(IdPosicion NVARCHAR(11))

	INSERT INTO #POSICIONES (IdPosicion)
	SELECT Value FROM dbo.Split(LEFT(@IDPosicionVigentes,(LEN(@IDPosicionVigentes))),',')

	UPDATE dbo.AX_Comparativa	
	SET Activo=0,
	EditadoEl=GETDATE()
	WHERE DataAreaId=@DataAreaID
	AND IdComparativa=@IdComparativa
	AND IdPosicion COLLATE DATABASE_DEFAULT NOT IN (SELECT LTRIM(IdPosicion) FROM #POSICIONES)		

END;

