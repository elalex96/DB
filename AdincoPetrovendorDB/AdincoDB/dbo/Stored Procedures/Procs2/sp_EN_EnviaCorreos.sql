USE Adinco
GO
DROP PROC IF EXISTS sp_EN_EnviaCorreos
GO
-- =============================================
-- Author:		Reynha Olvera
-- Create date:20180927
-- Description:	Envia correos a receptores de alterna, modulo entregables
-- =============================================
-- =============================================  
-- Author:  Daniel AC
-- Create date: 16/06/2025  
-- Description: SE RETORNA TABLA PARA ENVIO DE CORREOS CON DOBLE AUTENTIFICACIÓN
-- =============================================  
CREATE PROCEDURE [dbo].[sp_EN_EnviaCorreos]
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @Estatus INT,
    @ActividadSiguienteID INT, -- DONDE YA CAMBIO EL ESTATUS
    @ActividadIDActual INT -- ANTERIOR
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    ---------------------------------------------------------------------------
    -- 1. PREPARACIÓN DE TABLAS TEMPORALES
    ---------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#CorreosUsuarios') IS NOT NULL DROP TABLE #CorreosUsuarios;
    CREATE TABLE #CorreosUsuarios (id INT PRIMARY KEY IDENTITY(1, 1), CorreoReceptor NVARCHAR(MAX));

    IF OBJECT_ID('tempdb..#TemporalDatosCorreo') IS NOT NULL DROP TABLE #TemporalDatosCorreo;
    CREATE TABLE #TemporalDatosCorreo (id INT, NumeroContrato NVARCHAR(MAX), CorreoReceptor NVARCHAR(MAX), FechaName NVARCHAR(MAX), Descripcion NVARCHAR(MAX));

    IF OBJECT_ID('tempdb..#TemporalCorreosUsuario') IS NOT NULL DROP TABLE #TemporalCorreosUsuario;
    CREATE TABLE #TemporalCorreosUsuario (  
        Para VARCHAR(500),  
        Asunto VARCHAR(500),  
        Mensaje NVARCHAR(MAX),  
        De VARCHAR(200),
        CreadoPor INT
    );  

    DECLARE @correosReceptorAlerta NVARCHAR(MAX),
            @Texto1                NVARCHAR(MAX),
            @Texto2                NVARCHAR(MAX),
            @textoFecha            NVARCHAR(MAX),
            @NombreUsuarioRechazo  NVARCHAR(MAX),
            @AsuntoCorreoEstatus   NVARCHAR(MAX),
            @NombreContrato        NVARCHAR(MAX),
            @correosElabora        NVARCHAR(MAX),
            @NombreUsuarioElaboro VARCHAR(MAX),
            @CorreoUsuarioElaboro VARCHAR(MAX),
            @NombreUsuarioRealizaAccion VARCHAR(MAX),
            @EstadoActual    INT,
            @EstadoSiguiente    INT,
            @IdUsuarioSiguiente INT,
            @EsGrupoSiguiente INT,
            @NombreUsuarioSiguiente VARCHAR(MAX),
            @NombreDocumentoEntregable VARCHAR (MAX),
            @FechaLimiteElaboracion VARCHAR(MAX),
            @FechaLimiteRevision VARCHAR(MAX),
            @FechaLimiteAprobacion VARCHAR(MAX),
            @idVersion    INT;

    ---------------------------------------------------------------------------
    -- 2. OBTENCIÓN DE DATOS
    ---------------------------------------------------------------------------
    SELECT TOP 1 @idVersion = IdLineaTiempo
    FROM dbo.EN_HistorialAprobacionesLineaTiempo
    WHERE idInstanciaEntregable = @idInstanciaEntregable
    ORDER BY CreadoEn DESC;

    SELECT @correosReceptorAlerta = ReceptorAlerta
      FROM dbo.EN_InstanciasEntregable IE
      JOIN dbo.EN_ContratoEntregable CE 
	  ON IE.IdContratoEntregable = CE.IdContratoEntregable
     WHERE idInstanciaEntregable = @idInstanciaEntregable;

    SELECT @NombreContrato = NumeroContrato
      FROM dbo.CO_Contrato
     WHERE IdContrato = @idContrato;
     
    SELECT @NombreUsuarioRealizaAccion = Nombre FROM AP_Usuario WHERE UsuarioID = @idUsuario;
    
    SELECT @EstadoSiguiente = EstadoID FROM dbo.EN_Actividad WHERE ActividadID = @ActividadSiguienteID;
    SELECT @EstadoActual = EstadoID FROM dbo.EN_Actividad WHERE ActividadID = @ActividadIDActual;

    SELECT @NombreDocumentoEntregable = E.DocumentoEntregable,
           @FechaLimiteElaboracion = LTRIM(DAY(IE.FechasLimiteElaboracion)) + '-' + UPPER(DATENAME(MONTH, IE.FechasLimiteElaboracion)) + '-' + CONVERT(VARCHAR(4), YEAR(IE.FechasLimiteElaboracion)),
           @FechaLimiteRevision = LTRIM(DAY(IE.FechasLimiteRevision)) + '-' + UPPER(DATENAME(MONTH, IE.FechasLimiteRevision)) + '-' + CONVERT(VARCHAR(4), YEAR(IE.FechasLimiteRevision)),
           @FechaLimiteAprobacion = LTRIM(DAY(IE.FechasLimiteAprobacion)) + '-' + UPPER(DATENAME(MONTH, IE.FechasLimiteAprobacion)) + '-' + CONVERT(VARCHAR(4), YEAR(IE.FechasLimiteAprobacion))
    FROM dbo.EN_InstanciasEntregable IE
    JOIN dbo.EN_ContratoEntregable CE 
	ON IE.IdContratoEntregable = CE.IdContratoEntregable 
	AND IE.idInstanciaEntregable = @idInstanciaEntregable
    JOIN dbo.EN_Entregable E ON CE.IdEntregable = E.IdEntregable;

    SELECT @NombreUsuarioElaboro = U.Nombre, @CorreoUsuarioElaboro = U.Usuario
    FROM EN_HistorialAprobacionesLineaTiempo HAL
    JOIN AP_Usuario U 
	ON HAL.CreadoPor = U.UsuarioID
    WHERE idInstanciaEntregable = @idInstanciaEntregable AND IdLineaTiempo = @idVersion AND idTipoOperacion = 2;

    SELECT @IdUsuarioSiguiente = CASE ISNULL(EA.ActividadIDExcepcion,'') WHEN '' THEN A.idUsuario ELSE EA.idUsuario END,
           @NombreUsuarioSiguiente = CASE ISNULL(EA.ActividadIDExcepcion,'') WHEN '' THEN U.Nombre ELSE UE.Nombre END
    FROM EN_Actividad A
    JOIN AP_Usuario U 
	ON A.ActividadID = @ActividadSiguienteID 
	AND A.idUsuario = U.USUARIOID
    LEFT JOIN EN_ExcepcionesActividad EA 
	ON EA.ActividadIDExcepcion = @ActividadSiguienteID
    LEFT JOIN AP_Usuario UE 
	ON EA.idUsuario = UE.UsuarioID;

    IF((SELECT COUNT(1) FROM AP_Usuario WHERE UsuarioID = @IdUsuarioSiguiente AND IsGrupo = 1) >= 1)
    BEGIN
        SELECT DISTINCT @NombreUsuarioSiguiente = UG.Nombre + ' (Puede realizar la accion cualquiera de los siguientes usuarios: ' +
        STUFF((SELECT ', ' + U.Nombre FROM AP_Usuario U INNER JOIN EN_GruposUsuarios GUT ON U.UsuarioID = GUT.IdUsuario 
               WHERE GUT.IdGrupo = GU.IdGrupo FOR XML PATH('')), 1, 2, '') + ')'
        FROM EN_GruposUsuarios GU
        JOIN AP_Usuario AS UG 
		ON GU.IdGrupo = UG.UsuarioID
        WHERE GU.Activo = 1 AND UG.IsActivo = 1 AND GU.IdContrato = @IdContrato AND GU.IdGrupo = @IdUsuarioSiguiente;
    END

    ---------------------------------------------------------------------------
    -- 3. LÓGICA DE ESTATUS Y ARMADO DE MENSAJE
    ---------------------------------------------------------------------------
    IF (((@correosReceptorAlerta IS NOT NULL) OR (@correosReceptorAlerta <> '')) AND @Estatus <> 10000)
    BEGIN
        INSERT INTO #CorreosUsuarios (CorreoReceptor) SELECT splitdata FROM [dbo].[fnSplitString](@correosReceptorAlerta, ',');

        IF (@Estatus = 10002) -- Pasa a revision
        BEGIN
            SET @AsuntoCorreoEstatus = 'Entregable enviado a revisión';
            SELECT @Texto1 = 'Le informamos que el usuario ' + @NombreUsuarioRealizaAccion +',ha elaborado y enviado a revisión el entregable: ' + @NombreDocumentoEntregable +', con periodo: ' + @FechaLimiteAprobacion +',<BR/> del contrato: ' + @NombreContrato,
                   @Texto2 = CASE @EstadoSiguiente WHEN 10001 THEN 'Nombre del siguiente usuario revisor: ' + @NombreUsuarioSiguiente + '</BR>' WHEN 10002 THEN 'Nombre del siguiente usuario aprobador: ' + @NombreUsuarioSiguiente + '</BR>' ELSE '' END,
                   @textoFecha = 'Fecha de envio a revisión: ';
        END; 

        IF (@Estatus = 10004) -- APROBACION
        BEGIN
            SELECT @Texto1 = 'Le informamos que el entregable: ' + @NombreDocumentoEntregable + ', con periodo: ' + @FechaLimiteAprobacion+', <BR/>  del contrato: ' + @NombreContrato + ',ha sido ' + CASE @EstadoActual WHEN 10001 THEN 'revisado' WHEN 10002 THEN 'aprobado' END + ' por el usuario: ' + @NombreUsuarioRealizaAccion,
                   @Texto2 = 'Nombre del usuario elaborador: ' + @NombreUsuarioElaboro + CASE @EstadoSiguiente WHEN 10001 THEN 'Nombre del siguiente usuario revisor: ' + @NombreUsuarioSiguiente + '</BR>' WHEN 10002 THEN 'Nombre del siguiente usuario aprobador: ' + @NombreUsuarioSiguiente + '</BR>' ELSE '' END,
                   @textoFecha = 'Fecha de aprobación del entregable: ',
                   @AsuntoCorreoEstatus = CASE @EstadoActual WHEN 10001 THEN 'Entregable revisado' WHEN 10002 THEN 'Entregable aprobado' END;
        END;

        IF (@Estatus = 10005) -- Pasa a corrección
        BEGIN
            SET @AsuntoCorreoEstatus = 'Entregable enviado a corrección';
            SELECT @NombreUsuarioRechazo = Nombre FROM dbo.AP_Usuario WHERE UsuarioID = @idUsuario;
            SELECT @Texto1 = 'Le informamos que el entregable: ' + @NombreDocumentoEntregable + ', con periodo: ' + @FechaLimiteAprobacion + ',<BR/>  del contrato: ' + @NombreContrato + ',ha sido rechazado y mandado a correción por el usuario: ' + @NombreUsuarioRechazo,
                   @Texto2 = 'Nombre del usuario elaborador: ' + @NombreUsuarioElaboro,
                   @textoFecha = 'Fecha de rechazo del entregable: ';
        END;

        INSERT INTO #TemporalDatosCorreo (id, NumeroContrato, CorreoReceptor, FechaName, Descripcion)
        SELECT id, NumeroContrato, t.CorreoReceptor, @textoFecha + '' + +LTRIM(DAY(GETDATE())) + '-' + UPPER(DATENAME(MONTH, GETDATE())) + '-' + CONVERT(VARCHAR(4), YEAR(GETDATE())), 'Correos Receptor Alerta Entregable'
        FROM #CorreosUsuarios t JOIN CO_Contrato C ON C.IdContrato = @idContrato WHERE t.CorreoReceptor LIKE '%@%';

        INSERT INTO #TemporalCorreosUsuario (Para, Asunto, Mensaje, CreadoPor)
        SELECT tc.CorreoReceptor, @AsuntoCorreoEstatus,
               REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HTML, '##NOMBRE_USUARIO##', tc.CorreoReceptor), '##CONTRATO##', tc.NumeroContrato), '##MES##', tc.FechaName), '#TEXTO1#', @Texto1), '#TEXTO2#', @Texto2), '#MES#', FechaName),
               @idUsuario             
          FROM dbo.TA_Correo tac JOIN #TemporalDatosCorreo tc ON tc.Descripcion = tac.Descripcion WHERE tac.Descripcion = 'Correos Receptor Alerta Entregable';
    END
    ELSE IF (@Estatus = 10000) -- Para revisión 
    BEGIN
        SET @AsuntoCorreoEstatus = 'Enviado a revisión exitosamente';
        SELECT @Texto1 = 'Le informamos que el entregable: ' + @NombreDocumentoEntregable + ',<BR/> con periodo: ' + @FechaLimiteAprobacion + ',<BR/> del contrato: ' + @NombreContrato + ', ha sido elaborado y enviado a revisión exitosamente, por el usuario ' + @NombreUsuarioRealizaAccion,
               @Texto2 = CASE @EstadoSiguiente WHEN 10001 THEN 'Nombre del siguiente usuario revisor: ' + @NombreUsuarioSiguiente+ '</BR>' WHEN 10002 THEN 'Nombre del siguiente usuario aprobador: ' + @NombreUsuarioSiguiente + '</BR>' ELSE '' END,
               @textoFecha = 'Fecha de envio a revisión: ',
               @correosElabora = @CorreoUsuarioElaboro;

        INSERT INTO #TemporalDatosCorreo (id, NumeroContrato, CorreoReceptor, FechaName, Descripcion)
        SELECT 1, NumeroContrato, @correosElabora, @textoFecha + '' + +LTRIM(DAY(GETDATE())) + '-' + UPPER(DATENAME(MONTH, GETDATE())) + '-' + CONVERT(VARCHAR(4), YEAR(GETDATE())), 'Correos Receptor Alerta Entregable'
        FROM CO_Contrato C WHERE C.IdContrato = @idContrato;

        INSERT INTO #TemporalCorreosUsuario (Para, Asunto, Mensaje, CreadoPor)
        SELECT tc.CorreoReceptor, @AsuntoCorreoEstatus,
               REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(HTML, '##NOMBRE_USUARIO##', REPLACE(tc.CorreoReceptor , '''','' )), '##CONTRATO##', tc.NumeroContrato), '##MES##', tc.FechaName), '#TEXTO1#', @Texto1), '#TEXTO2#', @Texto2), '#MES#', FechaName),
               @idUsuario             
          FROM dbo.TA_Correo tac JOIN #TemporalDatosCorreo tc ON tc.Descripcion = tac.Descripcion WHERE tac.Descripcion = 'Correos Receptor Alerta Entregable';
    END;
        
    ---------------------------------------------------------------------------
    -- 4. ACTUALIZACIÓN DE FECHAS Y COPYRIGHT
    ---------------------------------------------------------------------------
    UPDATE #TemporalCorreosUsuario SET Mensaje = REPLACE(Mensaje,N'© 2018,',CONCAT('&copy; ',FORMAT(GETDATE(),'yyyy'),','))
    UPDATE #TemporalCorreosUsuario SET Mensaje = REPLACE(Mensaje,N'&copy; 2018,',CONCAT('&copy; ',FORMAT(GETDATE(),'yyyy'),','))

    ---------------------------------------------------------------------------
    -- 5. BLOQUE DE CORRECCIÓN PARA EVITAR INSERT EXEC (Compartir Tabla)
    ---------------------------------------------------------------------------
    -- Si la tabla compartida existe (creada por sp_En_DirectoAcprobacion), insertamos ahí
    IF OBJECT_ID('tempdb..#CorreosUsuario') IS NOT NULL
    BEGIN
        INSERT INTO #CorreosUsuario (Para, Asunto, Mensaje, CreadoPor)
        SELECT Para, Asunto, Mensaje, CreadoPor 
        FROM #TemporalCorreosUsuario;
    END

    -- Mantener el SELECT original para cuando se llama al SP de forma individual
    -- Esto se hace solo si NO se llamó desde otro procedimiento (Nivel 1)
    IF @@NESTLEVEL = 1
    BEGIN
        SELECT Para, Asunto, Mensaje, CreadoPor FROM #TemporalCorreosUsuario;
    END
END;
