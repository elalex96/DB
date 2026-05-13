---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	DANIEL AC
-- Create date: 06/04/2018
-- Description:	Consulta la relación de Documento Proveedor mediante tipo de persona fiscal
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_DocumentosProveedor_S3]
    @IdTipoRegimen INT,
    @IdProveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @ContadorTotalDocumentos INT;
    DECLARE @Incremento INT;
    DECLARE @IdDocumentoTemp INT;


    CREATE TABLE #TbTempDocumentos
    (
        IdRow INT,
        IdDocumento INT,
        IdTipoDocumento INT,
        NombreTipoDocumento VARCHAR(50),
        TipoValidacionDocumento VARCHAR(50) NULL,
        Fecha DATETIME NULL
    );

    --drop table #TbTempDocumentos
    INSERT INTO #TbTempDocumentos
    SELECT ROW_NUMBER() OVER (ORDER BY TPersona.[IdTipoDocumento] ASC) AS Row#,
           0,
           TPersona.[IdTipoDocumento],
           TPersona.[NombreTipoDocumento],
           'Sin Documento',
           GETDATE()
    FROM [dbo].[S_TipoDocumento] AS TPersona
        INNER JOIN [dbo].[S_TipoDocumentoTipoPersona] AS TDocumentoPersona
            ON TDocumentoPersona.[IdTipoDocumento] = TPersona.[IdTipoDocumento]
    WHERE TDocumentoPersona.[IdTipoRegimen] = @IdTipoRegimen
    ORDER BY TPersona.[IdTipoDocumento];



    SET @ContadorTotalDocumentos =
    (
        SELECT COUNT(IdRow) FROM #TbTempDocumentos
    );

    SET @Incremento = 1;

    WHILE @Incremento <= @ContadorTotalDocumentos
    BEGIN


        SET @IdDocumentoTemp =
        (
            SELECT IdTipoDocumento FROM #TbTempDocumentos WHERE IdRow = @Incremento
        );


        DECLARE @ContadorDocumentosExistentes INT;

        SET @ContadorDocumentosExistentes =
        (
            SELECT COUNT([IdDocumento]) AS ContadorDocumentosExistentes
            FROM [dbo].[S_Documento_S3]
            WHERE [IdTipoDocumento] = @IdDocumentoTemp
                  ---AND IdUsuario = @IdUsuario
                  AND IdProveedor = @IdProveedor
                  AND Activo = 1
        );

        --- Validar 
        IF @ContadorDocumentosExistentes > 0
        BEGIN

            -- Existe Documennto 
            --- Actualizar Estatatus

            DECLARE @ESTATUS NVARCHAR(50) = (
                                            (
                                                SELECT TOP 1
                                                    TVD.[TipoValidacion] AS ContadorDocumentosExistentes
                                                FROM [dbo].[S_Documento_S3] AS D
                                                    INNER JOIN [dbo].[S_TipoValidacionDoc] AS TVD
                                                        ON TVD.[IdTipoValidacionDoc] = D.[IdTipoValidacionDocumento]
                                                WHERE [IdTipoDocumento] = @IdDocumentoTemp
                                                      AND IdProveedor = @IdProveedor
                                                      AND Activo = 1
                                            )
                                            );

            DECLARE @IDDOCUMENTO INT = (
                                           SELECT
                                               (
                                                   SELECT TOP 1
                                                       D.[IdDocumento] AS IdDocumento
                                                   FROM [dbo].[S_Documento_S3] AS D
                                                   WHERE [IdTipoDocumento] = @IdDocumentoTemp
                                                         AND IdProveedor = @IdProveedor
                                                         AND Activo = 1
                                               ) AS VALOR
                                       );

            DECLARE @FECHA DATETIME = (
                                          SELECT
                                              (
                                                  SELECT TOP 1
                                                      D.[CreadoEl] AS fecha
                                                  FROM [dbo].[S_Documento_S3] AS D
                                                  WHERE [IdTipoDocumento] = @IdDocumentoTemp
                                                        AND IdProveedor = @IdProveedor
                                                        AND Activo = 1
                                              ) AS VALOR
                                      );


            --- ACTUALIZAR TABLA TEMPORAL 

            UPDATE #TbTempDocumentos
            SET TipoValidacionDocumento = @ESTATUS,
                IdDocumento = ISNULL(@IDDOCUMENTO, 0),
                Fecha = @FECHA
            WHERE IdRow = @Incremento;

        END;

        SET @Incremento = @Incremento + 1;

    END;


    SELECT TbTemp.IdTipoDocumento,
           TbTemp.NombreTipoDocumento,
           TbTemp.TipoValidacionDocumento,
           TbTemp.IdDocumento,
           TbTemp.Fecha
    FROM #TbTempDocumentos AS TbTemp;



END;