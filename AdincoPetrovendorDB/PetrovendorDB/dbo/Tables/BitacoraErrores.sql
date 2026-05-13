CREATE TABLE [dbo].[BitacoraErrores] (
    [IdError]       INT            IDENTITY (1, 1) NOT NULL,
    [HResult]       INT            NULL,
    [Mensaje]       NVARCHAR (MAX) NULL,
    [StackTrace]    NVARCHAR (MAX) NULL,
    [IdUsuario]     INT            NULL,
    [IdProveedor]   INT            NULL,
    [FechaRegistro] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdError] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

