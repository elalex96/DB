CREATE TABLE [dbo].[S_AutentificacionNuevoRegistro] (
    [IdSolicitudRegistroCuenta] INT            IDENTITY (1, 1) NOT NULL,
    [Correo]                    NVARCHAR (100) NULL,
    [CodigoVerificacion]        NVARCHAR (50)  NULL,
    [IdUsuario]                 INT            NULL,
    [FechaRegistro]             DATETIME       NULL,
    [Activo]                    BIT            NULL,
    CONSTRAINT [PK_S_AutentificacionNuevoRegistro] PRIMARY KEY CLUSTERED ([IdSolicitudRegistroCuenta] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

