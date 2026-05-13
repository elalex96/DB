USE [Petrovendor]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Validamos si el SP existe; si existe, lo eliminamos.
IF OBJECT_ID('[dbo].[CD_SP_EnvioXMLArchivoAdincoCompraDirecta]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[CD_SP_EnvioXMLArchivoAdincoCompraDirecta];
END
GO

-- =============================================
-- Author:		<DANIEL AC>
-- Create date: 01/10/2019
-- Description: Se removi� insertado de XML en Adinco. 
-- =============================================
-- Modificado por: Alexander Gomez
-- Fecha modificaci�n: 27/03/2026
-- Descripci�n: Correcci�n de error de nulos al insertar en FI_RelacionArchivoXMLAdinco, 
--              reacomodo del flujo de validaciones, implementaci�n de WITH (NOLOCK) 
--              en consultas de lectura y mejoras en los mensajes de la bit�cora de errores.
-- =============================================
CREATE PROCEDURE [dbo].[CD_SP_EnvioXMLArchivoAdincoCompraDirecta]
    @idFacturaP INT,
    @idFacturaAdinco INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    SET NOCOUNT ON; -- Mejora el rendimiento evitando mensajes de filas afectadas

    DECLARE @XMLAdinco INT = NULL,
            @XMLPetrovendor INT = NULL,
            @CANTIDAD_XMLS INT = 0,
            @EXISTE_RELACION INT = 0,
            @DETALLE NVARCHAR(MAX) = '';

    ---------------------------------------------------------------------------
    -- 1. OBTENER EL ID DEL XML DE PETROVENDOR
    ---------------------------------------------------------------------------
    SELECT TOP 1 @XMLPetrovendor = IdArchivoXml
    FROM dbo.FI_ArchivoXml WITH (NOLOCK)
    WHERE IdFactura = @idFacturaP;

    -- Si no existe el XML base en Petrovendor, registramos error y salimos
    IF ISNULL(@XMLPetrovendor, 0) = 0
    BEGIN
        INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
        VALUES (
            0, 
            CONCAT('Error: No se encontr� el ArchivoXml en Petrovendor para la factura ', @idFacturaP), 
            N'', @IdUsuario, 0, GETDATE()
        );
        RETURN; -- Terminamos la ejecuci�n ya que no hay nada que relacionar
    END

    ---------------------------------------------------------------------------
    -- 2. VALIDAR/INSERTAR XML EN ADINCO
    ---------------------------------------------------------------------------
    SELECT @CANTIDAD_XMLS = COUNT(IdArchivoXml)
    FROM Adinco.dbo.FI_ArchivoXml WITH (NOLOCK)
    WHERE IdFactura = @idFacturaAdinco;

    IF ISNULL(@CANTIDAD_XMLS, 0) = 0
    BEGIN
        -- Se copia el Archivo XML de la factura (Nota: se cambi� el filtro a @idFacturaP)
        INSERT INTO Adinco.dbo.FI_ArchivoXml
        (
            ArchivoXml, HashSHA256, IdFactura, IdContrato, 
            CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, Activo
        )
        SELECT 
            xmlP.ArchivoXml, xmlP.HashSHA256, @idFacturaAdinco, xmlP.IdContrato, 
            xmlP.CreadoPor, xmlP.CreadoEl, xmlP.ModificadoPor, xmlP.ModificadoEl, xmlP.Activo
        FROM Petrovendor.dbo.FI_ArchivoXml AS xmlP WITH (NOLOCK)
        WHERE xmlP.IdFactura = @idFacturaP; -- CORRECCI�N: Filtrar por la factura de origen (Petrovendor)

        SET @XMLAdinco = SCOPE_IDENTITY();

        -- Se registra en bit�cora que se tuvo que realizar la copia
        INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
        VALUES (
            0, 
            CONCAT('Aviso: No se hab�a encontrado XML de Adinco para su factura ', @idFacturaAdinco, '. Se copi� desde Petrovendor (Fac: ', @idFacturaP, ') con nuevo IdArchivoXml: ', ISNULL(CAST(@XMLAdinco AS VARCHAR), 'NULL')), 
            N'', @IdUsuario, 0, GETDATE()
        );
    END
    ELSE
    BEGIN
        -- Si ya existe, obtenemos su ID
        SELECT TOP 1 @XMLAdinco = IdArchivoXml
        FROM Adinco.dbo.FI_ArchivoXml WITH (NOLOCK)
        WHERE IdFactura = @idFacturaAdinco;
    END

    ---------------------------------------------------------------------------
    -- 3. VALIDAR E INSERTAR RELACI�N (Evitando errores de NULL)
    ---------------------------------------------------------------------------
    -- Verificamos de forma segura que ambas variables tengan un valor
    IF @XMLAdinco IS NOT NULL AND @XMLPetrovendor IS NOT NULL
    BEGIN
        -- Revisar si ya existe la relaci�n usando las variables que ya est�n llenas
        SELECT @EXISTE_RELACION = COUNT(IdRelacionArchivoXMLAdinco)
        FROM dbo.FI_RelacionArchivoXMLAdinco WITH (NOLOCK)
        WHERE IdArchivoXML = @XMLPetrovendor
          AND IdArchivoXMLAdinco = @XMLAdinco;

        IF ISNULL(@EXISTE_RELACION, 0) = 0
        BEGIN
            INSERT INTO dbo.FI_RelacionArchivoXMLAdinco (IdArchivoXML, IdArchivoXMLAdinco, CreadoEl, Observacion)
            VALUES (@XMLPetrovendor, @XMLAdinco, GETDATE(), '');
        END
        ELSE
        BEGIN
            SET @DETALLE = CONCAT('INTENTO:', CAST(GETDATE() AS NVARCHAR(200)), '. ');

            UPDATE dbo.FI_RelacionArchivoXMLAdinco
            SET Observacion = CONCAT(ISNULL(Observacion, ''), @DETALLE),
                EditadoEl = GETDATE()
            WHERE IdArchivoXML = @XMLPetrovendor
              AND IdArchivoXMLAdinco = @XMLAdinco;
        END
    END
    ELSE
    BEGIN
        -- Si llegamos aqu� y alguna es NULL, registramos el error en lugar de hacer 'crash'
        INSERT INTO dbo.BitacoraErrores (HResult, Mensaje, StackTrace, IdUsuario, IdProveedor, FechaRegistro)
        VALUES (
            1, 
            CONCAT('Error Cr�tico: No se pudo crear la relaci�n. @XMLPetrovendor: ', ISNULL(CAST(@XMLPetrovendor AS VARCHAR), 'NULL'), ' | @XMLAdinco: ', ISNULL(CAST(@XMLAdinco AS VARCHAR), 'NULL')), 
            N'Evit� caida en INSERT FI_RelacionArchivoXMLAdinco', @IdUsuario, 0, GETDATE()
        );
    END
END;
GO
