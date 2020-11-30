CREATE TABLE [dbo].[AM_Aprobacion] (
    [IdAprobacion]                INT            IDENTITY (10000, 1) NOT NULL,
    [IdTipoAprobacion]            INT            NULL,
    [IdStatusAprobacionM]         INT            NULL,
    [IdUsuario]                   INT            NULL,
    [IdTareaOrigen]               INT            NULL,
    [IdContrato]                  INT            NULL,
    [FechaCreacion]               DATETIME       NULL,
    [FechaModificacion]           DATETIME       NULL,
    [IdDocumento]                 INT            NULL,
    [ComentarioDocumento]         NVARCHAR (MAX) NULL,
    [ComentarioAprobacion]        NVARCHAR (MAX) NULL,
    [ComentarioAprobacionRechazo] NVARCHAR (MAX) NULL,
    [EsVisible]                   BIT            NULL,
    [NoVersion]                   INT            NULL,
    [TipoFlujo]                   INT            NULL,
    [NoSecuencia]                 INT            NULL,
    [ActualizadoByApp]            BIT            NULL,
    [IdPedido]                    INT            NULL,
    PRIMARY KEY CLUSTERED ([IdAprobacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
/****** Object:  Trigger [dbo].[NuevaNotificacion]    Script Date: 04/03/2019 07:04:28 p. m. ******/
--DROP TRIGGER NuevaNotificacion
CREATE TRIGGER [dbo].[NuevaNotificacion]
ON [dbo].[AM_Aprobacion]
FOR INSERT
AS
BEGIN
    DECLARE @NombreContrato VARCHAR(350);
	----------------------TABLA TEMPORAL DE AM_APROBACION-------------------
				CREATE TABLE #AM_Aprobacion
				(
				[IdAprobacion] [int] NOT NULL,
				[IdTipoAprobacion] [int] NULL,
				[IdStatusAprobacionM] [int] NULL,
				[IdUsuario] [int] NULL,
				[IdTareaOrigen] [int] NULL,
				[IdContrato] [int] NULL,
				[FechaCreacion] [datetime] NULL,
				[FechaModificacion] [datetime] NULL,
				[IdDocumento] [int] NULL,
				[ComentarioDocumento] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				[ComentarioAprobacion] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				[ComentarioAprobacionRechazo] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
				[EsVisible] [bit] NULL,
				[NoVersion] [int] NULL,
				[TipoFlujo] [int] NULL,
				[NoSecuencia] [int] NULL
				)
				------------ inserta todo lo de la tabla INSERTED
				INSERT INTO #AM_Aprobacion
				(
					IdAprobacion,
				    IdTipoAprobacion,
				    IdStatusAprobacionM,
				    IdUsuario,
				    IdTareaOrigen,
				    IdContrato,
				    FechaCreacion,
				    FechaModificacion,
				    IdDocumento,
				    ComentarioDocumento,
				    ComentarioAprobacion,
				    ComentarioAprobacionRechazo,
				    EsVisible,
				    NoVersion,
				    TipoFlujo,
				    NoSecuencia
				)SELECT Inserted.IdAprobacion, Inserted.IdTipoAprobacion, Inserted.IdStatusAprobacionM, Inserted.IdUsuario ,
						Inserted.IdTareaOrigen, Inserted.IdContrato, Inserted.FechaCreacion, Inserted.FechaModificacion ,
						Inserted.IdDocumento, Inserted.ComentarioDocumento, Inserted.ComentarioAprobacion ,
						Inserted.ComentarioAprobacionRechazo, Inserted.EsVisible, Inserted.NoVersion, Inserted.TipoFlujo ,
						Inserted.NoSecuencia FROM Inserted				
				--------------------------------------------------------------------------
				CREATE TABLE #UsuarioInsertados
				(IdUsuario INT,IdTareaOrigen int)
				INSERT INTO #UsuarioInsertados
				(IdUsuario,IdTareaOrigen)
				SELECT IdUsuario,IdTareaOrigen FROM Inserted-- cambiar a INSERTED
				---------------------------------------------------------------------------
    --Crear tabla temporal
    CREATE TABLE #OneSignalNotificaciones
    (
        Para NVARCHAR(200),
        Player NVARCHAR(200),
        TItulo nvarchar(max),
        Subtitulo nvarchar(max),
        Mensaje NVARCHAR(MAX),
        FechaCreacion DATETIME,
        FechaModificacion DATETIME,
        Enviado BIT,
		Enviar BIT,
		IdTareaOrigen int
    );

    --//Crear tabla temporal
    -- Seleccionar nombre del contrato

    SELECT DISTINCT
        @NombreContrato = CO_AreaContractual.NombreAreaContractual
    FROM AP_PerfilUsuario AS PU
        INNER JOIN AP_Usuario
            ON PU.UsuarioID = AP_Usuario.UsuarioID
        INNER JOIN AP_Perfil
            ON PU.PerfilID = AP_Perfil.IdPerfil
        INNER JOIN AP_Rol
            ON AP_Perfil.IdRol = AP_Rol.IdRol
        INNER JOIN CO_Contrato
            ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
        INNER JOIN CO_AreaContractual
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
    WHERE CO_Contrato.IdContrato =
    (
        SELECT DISTINCT IdContrato FROM Inserted
    );


	

    INSERT INTO #OneSignalNotificaciones
    (
        Para,
        Player,
		TItulo,
		Subtitulo,
		Mensaje,
		FechaCreacion,
		FechaModificacion,
		Enviado,
		Enviar,
		IdTareaOrigen
		)SELECT 
		AP.Usuario AS 'Para'
		,PL.PlayerId AS 'Player' 
		,CONCAT(TP.TipoAprobacion,' #',AM.IdTareaOrigen) AS 'Titulo'
		,CONCAT('Aprobación',' ',AM.IdTareaOrigen ) AS 'Subtitulo'
		,AM.ComentarioDocumento AS 'Mensaje'
		,GETDATE() AS 'FechaCreacion'
		,NULL AS 'FechaModificacion'
		,0 AS 'Enviado'
		,AM.EsVisible AS 'Enviar'
		,TEMP.IdTareaOrigen AS 'IdTareOrigen'
		FROM 
		#UsuarioInsertados AS TEMP
		INNER JOIN ap_usuario AS AP 
		ON TEMP.IdUsuario = AP.UsuarioID
		JOIN #AM_Aprobacion AS AM 
		ON AM.IdTareaOrigen = TEMP.IdTareaOrigen
		JOIN dbo.AM_OneSignalPlayers AS PL 
		ON PL.Usuario = AP.Usuario
		JOIN dbo.AM_TipoAprobacion AS TP 
		ON TP.idTipoAprobacion = AM.IdTipoAprobacion
  --  	SELECT 
		--AU.Usuario AS 'Para'
		--,PL.PlayerId AS 'Player'
		--,TP.TipoAprobacion AS 'Titulo'
		--,AP.ComentarioAprobacion AS 'Subtitulo'
		--,ap.ComentarioDocumento AS 'Mensaje'
		--,GETDATE() AS 'FechaCreacion'
		--,NULL AS 'FechaModificacion'
		--,0 AS 'Enviado'
		--,AP.EsVisible AS 'Enviar'
		--,AP.IdTareaOrigen AS 'IdTareaOrigen'
		--FROM dbo.#AM_Aprobacion AS AP
		--JOIN dbo.AP_Usuario AS AU
		--ON AP.IdUsuario = AU.UsuarioID
		--JOIN dbo.AM_OneSignalPlayers AS PL
		--ON PL.Usuario = AU.Usuario
		--JOIN dbo.AM_TipoAprobacion AS TP
		--ON TP.idTipoAprobacion = AP.IdTipoAprobacion
		--WHERE AU.Usuario IN (SELECT Usuario FROM dbo.AP_Usuario 
		--WHERE UsuarioID IN (SELECT IdUsuario FROM Inserted)) --SSF INSERTED
   
   INSERT INTO dbo.AM_OneSignalNotificaciones
   (
       Para,
       Player,
       TItulo,
       Subtitulo,
       Mensaje,
       FechaCreacion,
       FechaModificacion,
       Enviado,
       Enviar,
       IdTareaOrigen
   )
   SELECT Para,
       Player,
       TItulo,
       Subtitulo,
       Mensaje,
       FechaCreacion,
       FechaModificacion,
       Enviado,
       Enviar,
       IdTareaOrigen FROM  #OneSignalNotificaciones;
END;