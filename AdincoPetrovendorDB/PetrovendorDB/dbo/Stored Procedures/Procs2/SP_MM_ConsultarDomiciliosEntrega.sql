
-- =============================================
-- Author:      Daniel A Cruz
-- Create date: 12-05-17
-- Description:  Consultar domicilios de entrega previamente usados
--**************************************************************
-- Modified:      <Jose Roman>                                  
-- Updated date: <09/01/2018>                                   
-- Description: <Se elimina el elemento "0-Seleccione un domicilio" y se agregan parametros de contrato>            
--**************************************************************
-- Modified:      <Alexander Gomez>                                  
-- Updated date: <26/11/2021>                                   
-- Description: <optimzacion>            
--**************************************************************
CREATE  PROCEDURE [dbo].[SP_MM_ConsultarDomiciliosEntrega] 
    @IdProveedor INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    --DECLARE @NUM_DOMICILIOS INT   
    CREATE TABLE #DOMICILIOS(IdDomicilio int, Domicilio nvarchar(MAX))
    DECLARE @NUM_DOMICILIOS INT
    SET @NUM_DOMICILIOS = (SELECT COUNT([IdDomicilio])
                            FROM [dbo].[DG_Domicilio]
                            WHERE IdProveedor = @IdProveedor)
    IF @NUM_DOMICILIOS > 0 
        BEGIN 
            INSERT INTO  #DOMICILIOS(IdDomicilio, Domicilio)
            SELECT [IdDomicilio], CONCAT([Calle], ' ', [NoExterior] , ' ', [NoInterior], ' ',[Colonia] , ' ',[Municipio], ' ', [Estado],' ',[CodigoPostal] , ' (', CAST(TD.TipoDomicilio AS NVARCHAR(MAX)),')') AS Domicilio
            FROM  [dbo].[DG_Domicilio] AS D (NOLOCK)
            INNER JOIN DG_TipoDomicilio AS TD (NOLOCK) ON TD.IdTipoDomicilio = D.IdTipoDomicilio
            WHERE D.IdProveedor = @IdProveedor AND D.Activo = 1
        END 
    ELSE 
        BEGIN 
            INSERT INTO #DOMICILIOS(IdDomicilio, Domicilio)
            VALUES(0, 'No se encontro ningún resultado')
        END 
    SELECT * 
    FROM #DOMICILIOS
END