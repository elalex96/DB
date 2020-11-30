CREATE TABLE [dbo].[AP_BitacoraErrores] (
    [IdError]       INT            IDENTITY (1, 1) NOT NULL,
    [HResult]       INT            NULL,
    [Mensaje]       NVARCHAR (MAX) NULL,
    [StackTrace]    NVARCHAR (MAX) NULL,
    [IdUsuario]     INT            NULL,
    [IdContrato]    INT            NULL,
    [FechaRegistro] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdError] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [idx_BitacoraUsuario]
    ON [dbo].[AP_BitacoraErrores]([IdUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

