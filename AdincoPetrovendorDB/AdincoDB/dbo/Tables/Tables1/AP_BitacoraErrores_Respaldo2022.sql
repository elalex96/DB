CREATE TABLE [dbo].[AP_BitacoraErrores_Respaldo2022] (
    [IdError]       INT            IDENTITY (1, 1) NOT NULL,
    [HResult]       INT            NULL,
    [Mensaje]       NVARCHAR (MAX) NULL,
    [StackTrace]    NVARCHAR (MAX) NULL,
    [IdUsuario]     INT            NULL,
    [IdContrato]    INT            NULL,
    [FechaRegistro] DATETIME       NULL
);

