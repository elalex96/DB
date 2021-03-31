if exists (select * from sys.procedures where name = 'SP_EN_GuardarAvanceEntregableSeguimiento')
begin
	drop proc SP_EN_GuardarAvanceEntregableSeguimiento
end

go

-- =============================================  
-- Author:   Daniel AC  
-- Create date: 15/10/2020  
-- Description: Guardar avance de porcentaje de un Entregable Instancia 
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_EN_GuardarAvanceEntregableSeguimiento]
    @EntregableInstanciaId INT,
    @ClaveAvance VARCHAR(100),
    @UsuarioId INT,
    @ContratoId INT,
    @Estado VARCHAR(MAX),
    @TipoGuardado VARCHAR(MAX),
    @Comentario VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EntregableSeguimientoId INT;  
    DECLARE @PorcentajeXusuario FLOAT;
    DECLARE @PorcentajePorEstado FLOAT = CAST(100 AS FLOAT) / CAST(3 AS FLOAT); --> EL 100% DEL AVANCE ENTRE LOS 3 ESTADOS DEL ENTREGABLE
    DECLARE @PorcentajeGeneral FLOAT;
    DECLARE @Historial NVARCHAR(MAX);
    DECLARE @PorcentajeAvance FLOAT;
    DECLARE @NombreClave VARCHAR(MAX);
    DECLARE @NombreUsuario VARCHAR(MAX);
    DECLARE @EnAprobacion INT = 10002; --> ESTADO EN APROBACIÓN
    DECLARE @EnRevision INT = 10001; --> ESTADO EN REVISIÓN
    DECLARE @EnElaboracion INT = 10000; --> ESTADO EN ELABORACIÓN
    DECLARE @AprobadoInternamente INT = 10003; --> ESTADO APROBADO INTERNAMENTE
    DECLARE @EstadoIdModificado INT;
    DECLARE @EstadoIdActualEntregable INT;
    DECLARE @PorcentajeCompleto VARCHAR(MAX);
    DECLARE @PorcentajeSinInicia VARCHAR(MAX);
	declare @EsAdministrador bit
    DECLARE @UsuariosPorcentajes AS TABLE
    (
        EstadoId INT,
        PorcentajeXUsuario FLOAT,
        CantidadUsuarios INT
    );


	if exists(
	select		* 
	from		Ap_PerfilUsuario	pu
	inner join	AP_Perfil			p
	on			pu.PerfilID			=	p.IdPerfil
	inner join	AP_Rol				r
	on			p.IdRol				=	r.IdRol
	where		rol					like '%admin%'
	and			pu.UsuarioID		=	@UsuarioId
	and			p.IdContrato		=	@ContratoId
	)
	begin
		select	@EsAdministrador = 1
	end
	else
	begin
		select	@EsAdministrador = 0
	end

    /*TIPOS DE GUARDADO --> VARIABLE --> @TipoGuardado */
    -- 0 SI NO EXISTE REGISTROS DE SEGUIMIENTO SE CREA UN REGISTRO
    -- 1._REINICIAR --> PARA CUANDO EL ENTREGABLES ES REINICIADO (DESDE APROBADO INTERNAMENTE), O RECHAZADO (EN APROBACIÓN, EN REVISIÓN)
    -- 2._PERSONALIZADO --> PARA CUANDO EL USUARIO MODIFICA EL AVANCE DESDE LA PANTALLA	
    -- 3._SISTEMA --> PARA CUANDO EL ENTREGABLE CAMBIA DE ESTADO SE ACTUALIZA EL PORCENTAJE QUE LE CORRESPONDE AL ESTADO @PorcentajePorEstado
    -- 4._SISTEMA-ACUSE --> PARA VALIDAR SI EL AVANCE ESTA AL 100% SI NO SE ACTUALIZA AL 100%
    /*
	ESTE SP SE UTILIZA EN LOS SP´S , EN_CambioEstadoA,EN_CambioEstadoARevision,EN_sp_GuardaHistoricoIngresoAcuse,y en código	
	*/

    --VALIDAR SI EXISTE LA INSTANCIA SOLICITADA  
    IF NOT EXISTS
    (
        SELECT idInstanciaEntregable
        FROM dbo.EN_InstanciasEntregable
        WHERE idInstanciaEntregable = @EntregableInstanciaId
    )
    BEGIN
        RETURN;
    ---SI NO EXISTE DETENER EL GUARDADO
    END;

    --VALIDAR PORCENTAJES NO EXCEDAN DE 100% NI SEA MENOS DE 0%
    SELECT @PorcentajeAvance = Porcentaje,
           @NombreClave = NombreClave
    FROM dbo.EN_PorcentajeProgresoOpciones
    WHERE Clave = @ClaveAvance; --> PORCENTAJES NO INICIADO, COMPLETADO, EN PROGRESO

    --OBTENER NOMBRE PORCENTAJE COMPLETO
    SELECT @PorcentajeCompleto = NombreClave
    FROM dbo.EN_PorcentajeProgresoOpciones
    WHERE Clave = 'COMPLETADO';

    --VALIDAR PORCENTAJE NO PASE DEL 100%
    IF @PorcentajeAvance > 100
        SET @PorcentajeAvance = 100;
    IF @PorcentajeAvance < 0
        SET @PorcentajeAvance = 0;

    --NO NULOS 
    SET @PorcentajeAvance = ISNULL(@PorcentajeAvance, 0);
    SET @NombreClave = ISNULL(@NombreClave, 'No iniciado');

    --OBTENER NOMBRE DEL USUARIO
    SELECT @NombreUsuario = Nombre
    FROM dbo.AP_Usuario
    WHERE UsuarioID = @UsuarioId;

    --0._SI NO EXISTEN REGISTROS DE SEGUIMIENTO PARA LA INSTANCIA CREAR REGISTROS 
    EXEC dbo.SP_EN_CrearSeguimientoAvanceEntregable @EntregableInstanciaId = @EntregableInstanciaId, -- int
                                                    @UsuarioId = @UsuarioId,                         -- int
                                                    @ContratoId = @ContratoId;                       -- int

    --OBTENER LOS PORCENTAJES POR USUARIO SEGUN EL ESTADO
    --DIVIDIR EL PORCETAJE POR ESTADO ENTRE # DE USUARIOS EN EL ESTADO CORRESPONDIENTE 
    INSERT INTO @UsuariosPorcentajes
    (
        EstadoId,
        PorcentajeXUsuario,
        CantidadUsuarios
    )
    SELECT IdEstado,
           CAST(@PorcentajePorEstado AS FLOAT) / CAST(COUNT(UsuarioId) AS FLOAT),
           COUNT(UsuarioId)
    FROM dbo.EN_AvanceEntregableSeguimientoUsuario
    WHERE EntregableInstanciaId = @EntregableInstanciaId
          AND Activo = 1
    GROUP BY IdEstado;

	
    --1. OPCIÓN DE REINICIAR EL AVANCE DE LOS PORCENTAJES 
    IF @TipoGuardado = 'REINICIAR'
    BEGIN
        --OBTENER EL PORCENTAJE QUE TIENE ACTUALMENTE EL AVANCE GENERAL
        SELECT @PorcentajeAvance = Porcentaje
        FROM EN_AvanceEntregableSeguimiento
        WHERE EntregableInstanciaId = @EntregableInstanciaId;

        -- SE BORRAN LOS REGISTROS DE SEGUIMIENTO Y SEGUIMIENTO USUARIO, SOLO SE QUEDA EL HISTORIAL 
        DELETE EN_AvanceEntregableSeguimientoUsuario
        WHERE EntregableInstanciaId = @EntregableInstanciaId;

        DELETE EN_AvanceEntregableSeguimiento
        WHERE EntregableInstanciaId = @EntregableInstanciaId;


        IF @Comentario = 'SISTEMA'
        BEGIN
            --SE PERSONALIZA COMENTARIO SI ES ACTUALIZACIÓN POR QUE SE REINICIO EL FLUJO DEL ENTREGABLE 
            --SE LLAMA DESDE EL SP EN_CambioEstadoA
            SET @Historial
                = CONCAT(
                            @NombreUsuario,
                            ' reinicio el avance del entregable, debido a que se reinicio el flujo del documento entregable(Paso al estado Aprobación)'
                        );
        END;
        ELSE
        BEGIN
            --OPCIÓN POR SI SE REALIZA EL REINICIO MANUALMENTE
            SET @Historial = CONCAT(@NombreUsuario, ' reinicio el avance del entregable');
        END;

        INSERT INTO dbo.EN_AvanceEntregableHistorial
        (
            EntregableInstanciaId,
            IdEstado,
            Porcentaje,
            Detalle,
            AvancePersonalizado,
            CreadoPor,
            CreadoEl,
            Activo,
            ContratoId
        )
        VALUES
        (   @EntregableInstanciaId, -- EntregableInstanciaId - int
            NULL,                   -- IdEstado - int		
            CASE
                WHEN @PorcentajeAvance > 100 THEN
                    100
                ELSE
                    @PorcentajeAvance
            END,                    -- Porcentaje - float --> PONER AQUI EL PORCENTAJE QUE SE TENIA ANTES DE LA ELIMINACIÓN
            @Historial,             -- Detalle - nvarchar(max)
            1,                      -- AvancePersonalizado - bit
            @UsuarioId,             -- CreadoPor - int
            GETDATE(),              -- CreadoEl - datetime
            1,                      -- Activo - bit
            @ContratoId             -- ContratoId - int
            );
    END;

    --2.-SIRVE PARA CUANDO EL USUARIO AGREGA SU AVANCE DE PORCENTAJE POR INTERFAZ
    IF @TipoGuardado = 'PERSONALIZADO'
    BEGIN
		--select @Estado
        --FINALIZAR SI NO VIENE NINGUNA DE ESAS OPCIONES 
        IF @Estado NOT IN ( 'ELABORACION', 'REVISION', 'APROBACION' )
            RETURN;

        IF @Estado = 'ELABORACION'
        BEGIN
            --OBTENER EL PORCENTAJE QUE LE TOCA A CADA USUARIO POR EL ESTADO ACTUAL
            SELECT @PorcentajeXusuario = PorcentajeXUsuario
            FROM @UsuariosPorcentajes
            WHERE EstadoId = @EnElaboracion; --> EN ELABORACIÓN			

            --OBTENER EL PORCENTAJE SEGUN SU AVANCE
            -- SI LE TOCAN 33% PERO SU AVANCE ES DE 50% EL PORCENTAJE DEBERIA SER EL 16.3333%
            SET @PorcentajeXusuario = @PorcentajeXusuario * (CAST(@PorcentajeAvance AS FLOAT) / CAST(100 AS FLOAT));

            --ACTUALIZAR EL PORCENTAJE DEL USUARIO ACTUAL 
            UPDATE	dbo.EN_AvanceEntregableSeguimientoUsuario
            SET		Porcentaje									=	@PorcentajeXusuario,
					EditadoPor									=	@UsuarioId,
					EditadoEl									=	GETDATE(),
					NombreAvance								=	@NombreClave,
					ComentarioUsuario							=	@Comentario,
					FechaModificacionUsuario					=	GETDATE()
            WHERE	IdEstado									=	@EnElaboracion --> EN ELABORACIÓN
            AND		EntregableInstanciaId						=	@EntregableInstanciaId
            AND		Activo										=	1
            AND		((UsuarioId									=	@UsuarioId) or @EsAdministrador = 1)

            SET @Historial = CONCAT(@NombreUsuario, ' actualizó su avance ha: ', @NombreClave);
            SET @EstadoIdModificado = @EnElaboracion;

        END;

        IF @Estado = 'REVISION'
        BEGIN
			--select 'ok'
            SELECT @PorcentajeXusuario = PorcentajeXUsuario
            FROM @UsuariosPorcentajes
            WHERE EstadoId = @EnRevision; --> EN REVISIÓN	

            --OBTENER EL PORCENTAJE SEGUN SU AVANCE
            -- SI LE TOCAN 33% PERO SU AVANCE ES DE 50% EL PORCENTAJE DEBERIA SER EL 16.3333%
            SET @PorcentajeXusuario = @PorcentajeXusuario * (CAST(@PorcentajeAvance AS FLOAT) / CAST(100 AS FLOAT));
			select @PorcentajeXusuario
            --ACTUALIZAR EL PORCENTAJE DEL USUARIO ACTUAL 
            UPDATE	dbo.EN_AvanceEntregableSeguimientoUsuario
            SET		Porcentaje									=	@PorcentajeXusuario,
					EditadoPor									=	@UsuarioId,
					EditadoEl									=	GETDATE(),
					NombreAvance								=	@NombreClave,
					ComentarioUsuario							=	@Comentario,
					FechaModificacionUsuario					=	GETDATE()
            WHERE	IdEstado									=	@EnRevision --> EN REVISIÓN
            AND		Activo										=	1
            AND		EntregableInstanciaId						=	@EntregableInstanciaId
            AND		((UsuarioId									=	@UsuarioId) or @EsAdministrador = 1)

            --ACTUALIZA A TODOS LOS ELABORADORES 				

            UPDATE	AEU
            SET		Porcentaje									=	UP.PorcentajeXUsuario,
					EditadoPor									=	@UsuarioId,
					EditadoEl									=	GETDATE(),
					NombreAvance								=	@PorcentajeCompleto
            FROM	EN_AvanceEntregableSeguimientoUsuario		AEU
			JOIN	@UsuariosPorcentajes						UP
			ON		AEU.IdEstado								=	UP.EstadoId
            WHERE	AEU.IdEstado								=	@EnElaboracion --> EN ELABORACIÓN
			AND		EntregableInstanciaId						=	@EntregableInstanciaId
			AND		Activo										=	1;

            SET @Historial = CONCAT(@NombreUsuario, ' actualizó su avance ha: ', @NombreClave);
            SET @EstadoIdModificado = @EnRevision;
        END;

        IF @Estado = 'APROBACION'
        BEGIN

            SELECT @PorcentajeXusuario = PorcentajeXUsuario
            FROM @UsuariosPorcentajes
            WHERE EstadoId = @EnAprobacion; --> EN APROBACIÓN	

            --OBTENER EL PORCENTAJE SEGUN SU AVANCE
            -- SI LE TOCAN 33% PERO SU AVANCE ES DE 50% EL PORCENTAJE DEBERIA SER EL 16.3333%
            SET @PorcentajeXusuario = @PorcentajeXusuario * (CAST(@PorcentajeAvance AS FLOAT) / CAST(100 AS FLOAT));

            --ACTUALIZAR EL PORCENTAJE DEL USUARIO ACTUAL 
            UPDATE dbo.EN_AvanceEntregableSeguimientoUsuario
            SET Porcentaje = @PorcentajeXusuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @NombreClave,
                ComentarioUsuario = @Comentario,
                FechaModificacionUsuario = GETDATE()
            WHERE IdEstado = @EnAprobacion --> EN APROBACIÓN	
                  AND Activo = 1
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND ((UsuarioId	 =	@UsuarioId) or @EsAdministrador = 1)


            --ACTUALIZA A TODOS REVISORES 			 
            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnRevision --> EN REVISIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            --ACTUALIZA A TODOS ELABORADORES 

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnElaboracion --> EN ELABORACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            SET @Historial = CONCAT(@NombreUsuario, ' actualizó su avance ha: ', @NombreClave);
            SET @EstadoIdModificado = @EnAprobacion;
        END;

        --ACTUALIZA EL PORCENTAJE GENERAL DE AVANCE DEL ENTREGABLE INSTANCIA

        SELECT @PorcentajeGeneral = CASE
                                        WHEN SUM(AEU.Porcentaje) > 100 THEN
                                            100
                                        ELSE
                                            SUM(AEU.Porcentaje)
                                    END
        FROM dbo.EN_AvanceEntregableSeguimientoUsuario AEU
        WHERE AEU.EntregableInstanciaId = @EntregableInstanciaId
              AND AEU.Activo = 1;

        UPDATE AE
        SET AE.Porcentaje = @PorcentajeGeneral,
            AE.EditadoPor = @UsuarioId,
            AE.EditadoEl = GETDATE()
        FROM dbo.EN_AvanceEntregableSeguimiento AE
        WHERE AE.EntregableInstanciaId = @EntregableInstanciaId
              AND AE.Activo = 1;

        INSERT INTO dbo.EN_AvanceEntregableHistorial
        (
            EntregableInstanciaId,
            IdEstado,
            Porcentaje,
            Detalle,
            Comentario,
            AvancePersonalizado,
            CreadoPor,
            CreadoEl,
            Activo,
            ContratoId
        )
        VALUES
        (   @EntregableInstanciaId, -- EntregableInstanciaId - int
            @EstadoIdModificado,    -- IdEstado - int		
            @PorcentajeXusuario,    -- Porcentaje - float
            @Historial,             -- Detalle - nvarchar(max)
            @Comentario,            -- Comentario -nvarchar(max)
            1,                      -- AvancePersonalizado - bit
            @UsuarioId,             -- CreadoPor - int
            GETDATE(),              -- CreadoEl - datetime
            1,                      -- Activo - bit
            @ContratoId             -- ContratoId - int
            );


    END;

    --3.- SIRVE PARA CUANDO EL ENTREGABLE CAMBIA DE ESTADO, SE DEBE ACTUALIZAR EL PORCENTAJE TOTAL ASIGNADO AL ESTADO ACTUAL Y EL DE SUS ESTADOS ANTERIORES
    IF @TipoGuardado = 'SISTEMA'
    BEGIN
        --FINALIZAR SI NO VIENE NINGUNA DE ESAS OPCIONES 
        IF @Estado NOT IN ( 'ELABORACION', 'REVISION', 'APROBACION' )
            RETURN;

        IF @Estado = 'ELABORACION'
        BEGIN

            --ACTUALIZA A TODOS LOS ELABORADORES 

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnElaboracion --> EN ELABORACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            SET @Historial = N'El documento entregable paso al estado Revisión';
            SET @EstadoIdModificado = @EnAprobacion;
        END;

        IF @Estado = 'REVISION'
        BEGIN

  --ACTUALIZA A TODOS LOS REVISORES 	

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnRevision --> EN REVISIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            --ACTUALIZA A TODOS LOS ELABORADORES 

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnElaboracion --> EN ELABORACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            SET @Historial = N'El documento entregable paso al estado Aprobación';
            SET @EstadoIdModificado = @EnRevision;

        END;

        IF @Estado = 'APROBACION'
        BEGIN

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnAprobacion --> EN APROBACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            --ACTUALIZA A TODOS LOS REVISORES 	

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnRevision --> EN REVISIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            --ACTUALIZA A TODOS LOS ELABORADORES 

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnElaboracion --> EN ELABORACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            SET @Historial = N'El documento entregable paso al estado aprobado internamente';
            SET @EstadoIdModificado = @EnAprobacion;
        END;

        --ACTUALIZA EL PORCENTAJE GENERAL DE AVANCE DEL ENTREGABLE INSTANCIA

        SELECT @PorcentajeGeneral = CASE
                                        WHEN SUM(AEU.Porcentaje) > 100 THEN
                                            100
                                        ELSE
                                            SUM(AEU.Porcentaje)
                                    END
        FROM dbo.EN_AvanceEntregableSeguimientoUsuario AEU
        WHERE AEU.EntregableInstanciaId = @EntregableInstanciaId
              AND AEU.Activo = 1;

        UPDATE AE
        SET AE.Porcentaje = @PorcentajeGeneral,
            AE.EditadoPor = @UsuarioId,
            AE.EditadoEl = GETDATE()
        FROM dbo.EN_AvanceEntregableSeguimiento AE
        WHERE AE.EntregableInstanciaId = @EntregableInstanciaId
              AND AE.Activo = 1;

        INSERT INTO dbo.EN_AvanceEntregableHistorial
        (
            EntregableInstanciaId,
            IdEstado,
            Porcentaje,
            Detalle,
            AvancePersonalizado,
            CreadoPor,
            CreadoEl,
            Activo,
            ContratoId
        )
        VALUES
        (   @EntregableInstanciaId, -- EntregableInstanciaId - int
            @EstadoIdModificado,    -- IdEstado - int		
            @PorcentajePorEstado,   -- Porcentaje - float
            @Historial,             -- Detalle - nvarchar(max)
            0,                      -- AvancePersonalizado - bit
            @UsuarioId,             -- CreadoPor - int
            GETDATE(),              -- CreadoEl - datetime
            1,                      -- Activo - bit
            @ContratoId             -- ContratoId - int
            );


    END;

    --4._SIRVE PARA CUANDO SE CARGA EL ACUSE, SE VALIDA EL AVANCE ESTE EL 100% SI NO SE TIENE QUE ACTUALIZAR
    IF @TipoGuardado = 'SISTEMA-ACUSE'
    BEGIN

        --VALIDAR SI YA TIENE EL 100%
        SELECT @PorcentajeGeneral = CASE
                                        WHEN SUM(AEU.Porcentaje) > 100 THEN
                                            100
                                        ELSE
                                            SUM(AEU.Porcentaje)
                                    END
        FROM dbo.EN_AvanceEntregableSeguimientoUsuario AEU
        WHERE AEU.EntregableInstanciaId = @EntregableInstanciaId
              AND AEU.Activo = 1;

        --> SI EL PORCENTAJE NO ES 100% ACTUALIZAR EL DE TODOS LOS USUARIOS Y EL DEL AVANCE GENERAL
        IF @PorcentajeGeneral <> CAST(100 AS FLOAT)
        BEGIN

            --ACTUALIZA A TODOS LOS APROBADORES 
            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnAprobacion --> EN APROBACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            --ACTUALIZA A TODOS LOS REVISORES 	

            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnRevision --> EN REVISIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            --ACTUALIZA A TODOS LOS ELABORADORES 
            UPDATE AEU
            SET Porcentaje = UP.PorcentajeXUsuario,
                EditadoPor = @UsuarioId,
                EditadoEl = GETDATE(),
                NombreAvance = @PorcentajeCompleto
            FROM EN_AvanceEntregableSeguimientoUsuario AEU
                JOIN @UsuariosPorcentajes UP
                    ON AEU.IdEstado = UP.EstadoId
            WHERE AEU.IdEstado = @EnElaboracion --> EN ELABORACIÓN
                  AND EntregableInstanciaId = @EntregableInstanciaId
                  AND Activo = 1;

            SET @Historial = N'Se cargo el acuse del documento entregable';
            SET @EstadoIdModificado = NULL;

            --ACTUALIZA EL PORCENTAJE GENERAL DE AVANCE DEL ENTREGABLE INSTANCIA
            UPDATE AE
            SET AE.Porcentaje = 100, --> AL SUBIR EL ACUSE EN TEORIA EL ENTREGABLE YA ESTA APROBADO
    AE.EditadoPor = @UsuarioId,
                AE.EditadoEl = GETDATE()
            FROM dbo.EN_AvanceEntregableSeguimiento AE
            WHERE AE.EntregableInstanciaId = @EntregableInstanciaId
                  AND AE.Activo = 1;

            INSERT INTO dbo.EN_AvanceEntregableHistorial
            (
                EntregableInstanciaId,
                IdEstado,
                Porcentaje,
                Detalle,
                AvancePersonalizado,
                CreadoPor,
                CreadoEl,
                Activo,
                ContratoId
            )
            VALUES
            (   @EntregableInstanciaId, -- EntregableInstanciaId - int
                NULL,                   -- IdEstado - int		
                100,                    -- Porcentaje - float
                @Historial,             -- Detalle - nvarchar(max)
                0,                      -- AvancePersonalizado - bit
                @UsuarioId,             -- CreadoPor - int
                GETDATE(),              -- CreadoEl - datetime
                1,                      -- Activo - bit
                @ContratoId             -- ContratoId - int
                );
        END;

    END;

END;


