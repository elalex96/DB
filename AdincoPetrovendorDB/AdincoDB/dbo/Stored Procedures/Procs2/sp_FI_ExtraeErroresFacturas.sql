IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_FI_ExtraeErroresFacturas'
)
    DROP PROCEDURE sp_FI_ExtraeErroresFacturas;
GO

-- =============================================
-- Author:	Reyna Olvera
-- Create date:25/06
-- Description:	Extrae las actividades
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajuste en el nombrado de las tablas
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ExtraeErroresFacturas]
    @idContrato INT,
    @idUsuario INT,
    @Error VARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;

    /**/
    DECLARE @ErrorUUID VARCHAR(1000)

    /**/
    INSERT INTO FI_ErroresCargaFactura
    (
        Error,
        IdContrato,
        CreadoPor,
        CreadoEl,
        ModificadoPor,
        ModificadoEl,
        Activo
    )
    VALUES
    (@Error, @idContrato, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1);

    /**/
    IF (@Error LIKE '%existe%')
    BEGIN
        SET @ErrorUUID
            = LTRIM(RTRIM(REPLACE(@Error, 'Excepción: La factura que desea insertar ya existe UUID: ', '')));
        SET @ErrorUUID
            = ISNULL(
                        NULLIF(SUBSTRING(@ErrorUUID, 0, CHARINDEX(' ', @ErrorUUID, PATINDEX('% [^ ]%', @ErrorUUID))), ''),
                        @ErrorUUID
                    )

        SELECT '<div class="alert alert-warning alert-dismissable">
					<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>¡Alerta! </strong>' + REPLACE(@Error, 'Excepción:', '') + ', en el contrato '
               + CO_Contrato.NumeroContrato + ' </div>' AS error
        FROM FI_Factura (NOLOCK)
            JOIN CO_Contrato (NOLOCK)
                ON FI_Factura.IdContrato = CO_Contrato.IdContrato
        WHERE FI_Factura.UUID = @ErrorUUID;

    END
    /**/
    ELSE
    BEGIN
        IF (@Error LIKE '%Verifique sus datos%' OR @Error LIKE '%no es un XML%')
        BEGIN
            SELECT '<div class="alert alert-warning alert-dismissable">
					<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>¡Alerta! </strong>' + @Error + ' </div>' AS error;
        END
        /**/
        ELSE
        BEGIN
            SELECT '<div class="alert alert-danger alert-dismissable">
					<button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                                 <strong>¡Error! </strong>' + REPLACE(REPLACE(@Error, 'Excepción:', ''), 'Error:', '') + ' </div>' AS error;
        END;
    END;
END;