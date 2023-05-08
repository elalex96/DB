CREATE PROCEDURE [dbo].[sp_AP_MuestraLoyoutContrato]--10061,3,10000
    @idUsuario INT = 1,
    @idContrato INT,
    @idPagina INT
AS
BEGIN
    -- =============================================
    -- Author:	Reyna Olvera
    -- Create date: 16/07/2018
    -- Description:	Extrae el nombre de como se vera al descargar el archivo y el url de donde se encuentra
    -- 20181207	BAAC	Se modifica para descargar todos los formatos de cromatografia de SCOC
    -- =============================================
    SET NOCOUNT ON;

    IF @idPagina IN ( 10000, 10003 )
    BEGIN
        --   SELECT URL,
        --          Nombre
        --   FROM AP_NameLayoutImportacion
        --   WHERE idContrato = @idContrato
        --         AND
        --         (
        --             idPagina = 10003
        --             OR idPagina = 10000
        --         );

        SELECT IdFormatoProduccionAWS,
               Bucket,
               Folder,
               UUIDAmazon,
               NombreArchivo,
               Meta
        FROM PR_FormatoProduccionAWS doc
        WHERE IdTipoFormato IN ( 10003, 10000 )
              AND IdContrato = @idContrato;
    END;
    ELSE
    BEGIN
        IF @idPagina IN ( 10004, 10005, 10006, 10007, 10008, 10009 )
        BEGIN
            --SELECT URL,
            --	   Nombre
            --FROM AP_NameLayoutImportacion
            --WHERE idContrato = 10010 --@idContrato TODOS LOS FORMATOS ESTAN EN EL CONTRATO DE EK-BALAM
            --	  AND idPagina BETWEEN 10004 AND 10009

            SELECT IdFormatoProduccionAWS,
                   Bucket,
                   Folder,
                   UUIDAmazon,
                   NombreArchivo,
                   Meta
            FROM PR_FormatoProduccionAWS doc
            WHERE IdTipoFormato
                  BETWEEN 10004 AND 10009
                  AND IdContrato = 10010;

        END;
        ELSE
        BEGIN
            --SELECT URL,
            --	   Nombre
            --FROM AP_NameLayoutImportacion
            --WHERE idContrato = @idContrato
            --AND idPagina = @idPagina

            SELECT IdFormatoProduccionAWS,
                   Bucket,
                   Folder,
                   UUIDAmazon,
                   NombreArchivo,
                   Meta
            FROM PR_FormatoProduccionAWS doc
            WHERE IdTipoFormato = @idPagina
                  AND IdContrato = @idContrato;
        END;
    END;
END;
