CREATE TABLE [dbo].[BitacoraErrores_Respaldo2022] (
    [IdError]       INT            IDENTITY (1, 1) NOT NULL,
    [HResult]       INT            NULL,
    [Mensaje]       NVARCHAR (MAX) NULL,
    [StackTrace]    NVARCHAR (MAX) NULL,
    [IdUsuario]     INT            NULL,
    [IdProveedor]   INT            NULL,
    [FechaRegistro] DATETIME       NULL
);

