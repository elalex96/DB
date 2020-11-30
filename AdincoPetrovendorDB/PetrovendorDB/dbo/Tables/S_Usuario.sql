CREATE TABLE [dbo].[S_Usuario] (
    [IdUsuario]                   INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]                      NVARCHAR (100) NULL,
    [Correo]                      NVARCHAR (200) NULL,
    [Contrasena]                  NVARCHAR (MAX) NULL,
    [Activo]                      BIT            NULL,
    [IdTipoUsuario]               INT            NULL,
    [FechaRegistro]               DATETIME       NULL,
    [FechaActivacion]             DATETIME       NULL,
    [IsEliminado]                 BIT            NULL,
    [ImagenPerfil]                NVARCHAR (50)  NULL,
    [Telefono]                    VARCHAR (50)   NULL,
    [MasterRedireccionar]         INT            NULL,
    [IdUsuarioADINCO]             INT            NULL,
    [CorreoVerificado]            BIT            NULL,
    [NotificacionActualizaciones] BIT            NULL,
    CONSTRAINT [PK_S_Usuario] PRIMARY KEY CLUSTERED ([IdUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_Usuario__IdTip__50FB042B] FOREIGN KEY ([IdTipoUsuario]) REFERENCES [dbo].[S_TipoUsuario] ([IdTipoUsuario])
);


GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/05/2019
-- Description:	Modificacion de la devolucion de el resultado del traigger (generaba error).
-- =============================================
CREATE TRIGGER [dbo].[TR_S_ActualizaUsuario] ON [dbo].[S_Usuario]
AFTER UPDATE
AS
     BEGIN
	---- SET NOCOUNT ON added to prevent extra result sets from
	---- interfering with SELECT statements.


         --UPDATE A
         --  SET
         --      A.Nombre = i.Nombre,
         --      A.Contraseña = i.Contrasena,
         --      A.ModificadoEl = GETDATE(),
         --      a.imgsrc = i.ImagenPerfil
         --FROM Adinco.dbo.AP_Usuario A
         --     JOIN INSERTED I ON A.UsuarioID = I.IdUsuarioADINCO
         --WHERE A.UsuarioID = I.IdUsuarioADINCO;
    -- Insert statements for trigger here

	DECLARE @IDUSUARIO INT  = (SELECT TOP 1 Inserted.IdUsuario FROM Inserted);

 SELECT @IDUSUARIO  AS IdUsuario

     END;
