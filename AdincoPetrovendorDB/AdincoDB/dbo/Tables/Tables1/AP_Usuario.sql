CREATE TABLE [dbo].[AP_Usuario] (
    [UsuarioID]        INT             IDENTITY (1, 1) NOT NULL,
    [Usuario]          VARCHAR (MAX)   NOT NULL,
    [Contraseña]       VARCHAR (MAX)   NOT NULL,
    [Nombre]           VARCHAR (MAX)   NOT NULL,
    [IsActivo]         BIT             CONSTRAINT [DF_Usuarios_Activo] DEFAULT ((0)) NOT NULL,
    [fchRegistro]      DATETIME        NOT NULL,
    [IsEliminado]      BIT             CONSTRAINT [DF_Usuarios_Eliminado] DEFAULT ((0)) NULL,
    [imgsrc]           VARCHAR (MAX)   CONSTRAINT [DF_AP_Usuario_imgsrc] DEFAULT ('../../assets/image-resources/UserPhoto/10015.png') NULL,
    [UltimoAcceso]     DATETIME        NULL,
    [Idioma]           INT             CONSTRAINT [DF_AP_Usuario_Idioma] DEFAULT ((1)) NULL,
    [CreadoPor]        INT             NULL,
    [IdTipoUsuario]    INT             NULL,
    [Sello]            NVARCHAR (MAX)  NULL,
    [image]            VARBINARY (MAX) NULL,
    [Foto]             IMAGE           NULL,
    [ModificadoPor]    INT             NULL,
    [ModificadoEl]     DATETIME        NULL,
    [TFAuthentication] BIT             NULL,
    [NumeroCelular]    NVARCHAR (20)   NULL,
    [CodigoPais]       INT             NULL,
    [IdRuta]           INT             CONSTRAINT [DF_AP_Usuario_IdRuta] DEFAULT ((1)) NULL,
    [Pass]             VARBINARY (MAX) NULL,
    [Salt]             VARBINARY (MAX) NULL,
    [IsGrupo]          BIT             NULL,
    [Dominio]          VARCHAR (100)   NULL,
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([UsuarioID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_Usuario_AP_Rutas] FOREIGN KEY ([IdRuta]) REFERENCES [dbo].[AP_Rutas] ([idRuta]),
    CONSTRAINT [FK_CodigoPais] FOREIGN KEY ([CodigoPais]) REFERENCES [dbo].[AP_Paises] ([idPais])
);


GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 24 Septiembre 2017
-- Description:	Actualiza en Petrovendor Datos de Usuario
-- =============================================
CREATE TRIGGER [dbo].[AP_Usuario_UPDATE] ON [dbo].[AP_Usuario]
AFTER UPDATE
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

         UPDATE PETROVENDOR
           SET
               Nombre = I.Nombre,
               Correo = I.Usuario,
               Contrasena = I.Contraseña,
               Activo = I.IsActivo,
               FechaRegistro = I.fchRegistro,
               FechaActivacion = GETDATE(),
               IsEliminado = I.IsEliminado,
               ImagenPerfil = I.imgsrc,
               IdUsuarioADINCO = UsuarioID
         FROM Petrovendor.dbo.S_Usuario PETROVENDOR
              JOIN INSERTED I ON PETROVENDOR.IdUsuarioADINCO  = I.UsuarioID;

    -- Insert statements for trigger here

     END;

GO
DISABLE TRIGGER [dbo].[AP_Usuario_UPDATE]
    ON [dbo].[AP_Usuario];


GO
CREATE TRIGGER [dbo].[AP_Usuario_INSERT] ON [dbo].[AP_Usuario]
FOR INSERT
NOT FOR REPLICATION
AS
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 29-06-17
-- Description:	
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 27/03/2023
-- Description:	Agregado del dominio al agregar un usuario
-- =============================================
     BEGIN
	---- SET NOCOUNT ON added to prevent extra result sets from
	---- interfering with SELECT statements.
 --        IF @@ROWCOUNT = 0
 --            GOTO FIN;

         SET NOCOUNT ON;
-- VALIDAMOS SI YA EXISTE EL USUARIO EN LA TABLA S_USUARIO DE PETROVENDOR CON EL CORREO
         IF 0 =
         (
             SELECT COUNT(1)
             FROM Petrovendor.dbo.S_Usuario PETROVENDOR
                  JOIN INSERTED I ON PETROVENDOR.Correo COLLATE Modern_Spanish_CI_AS = I.Usuario
         )
            AND 0 =
         (
             SELECT COUNT(1)
             FROM Petrovendor.dbo.S_Usuario PETROVENDOR
                  JOIN INSERTED I ON PETROVENDOR.IdUsuarioADINCO = I.UsuarioID
         )
             BEGIN
			 -- SE INSERTA EL USUARIO EN PETROVENDOR
                 INSERT INTO [Petrovendor].[dbo].[S_Usuario]
                 (
				  [Nombre],
                  [Correo],
                  [Contrasena],
                  [Activo],
                  [FechaRegistro],
                  [FechaActivacion],
                  [IsEliminado],
                  [ImagenPerfil],
                  [IdUsuarioADINCO],
				  Dominio
                 )
                        SELECT Nombre,
                               Usuario,
                               Contraseña,
                               IsActivo,
                               fchRegistro,
                               GETDATE(),
                               0,
                               imgsrc,
                               UsuarioID,
							   SUBSTRING(Usuario, CHARINDEX('@', Usuario) + 1, LEN(Usuario))
                        FROM INSERTED
                        WHERE IsActivo = 1
						AND Isnull(IsGrupo,0) = 0;
         END;
     END;

