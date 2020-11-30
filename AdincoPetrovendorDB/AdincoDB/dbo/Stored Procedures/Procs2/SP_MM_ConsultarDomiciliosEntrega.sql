-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 12-05-17
-- Description:	 Consultar domicilios de entrega previamente usados
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarDomiciliosEntrega] 
	-- Add the parameters for the stored procedure here

@IdProveedor INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @NUM_DOMICILIOS INT;
         CREATE TABLE #DOMICILIOS
         (IdDomicilio INT,
          Domicilio   NVARCHAR(MAX)
         );
         SET @NUM_DOMICILIOS =
         (
             SELECT COUNT([IdDomicilioEntrega])
             FROM [dbo].[MM_DomicilioEntregaPedido]
             WHERE IdProveedor = @IdProveedor
         );
         IF @NUM_DOMICILIOS > 0
             BEGIN
                 INSERT INTO #DOMICILIOS
                 (IdDomicilio,
                  Domicilio
                 )
                 VALUES
                 (0,
                  'Seleccionar una opción'
                 );
                 INSERT INTO #DOMICILIOS
                 (IdDomicilio,
                  Domicilio
                 )
                        SELECT [IdDomicilioEntrega],
                               CONCAT([Calle], ' ', [NoExterior], ' ', [NoInterior], ' ', [Colonia], ' ', [Municipio], ' ', [Estado], [CP], ' ', [Referencia]) AS Domicilio
                        FROM [dbo].[MM_DomicilioEntregaPedido]
                        WHERE IdProveedor = @IdProveedor;
         END;
             ELSE
             BEGIN
                 INSERT INTO #DOMICILIOS
                 (IdDomicilio,
                  Domicilio
                 )
                 VALUES
                 (0,
                  'No se encontro ningún resultado'
                 );
         END;
         SELECT *
         FROM #DOMICILIOS;
     END;
