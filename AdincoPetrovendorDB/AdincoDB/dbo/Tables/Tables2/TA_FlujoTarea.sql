CREATE TABLE [dbo].[TA_FlujoTarea] (
    [IdFlujoTarea]    INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]          NVARCHAR (MAX) NULL,
    [Descripcion]     NVARCHAR (MAX) NULL,
    [IdTipoFlujo]     INT            NULL,
    [IdTipoOperacion] INT            NULL,
    [Activo]          BIT            NULL,
    [IdProveedor]     INT            NULL,
    [Condicion]       BIT            NULL,
    [FechaCreacion]   DATETIME       NULL,
    [CreadorPor]      INT            NULL,
    [Mensaje]         NVARCHAR (MAX) NULL,
    [IdVencimiento]   INT            NULL,
    [IdPrioridad]     INT            NULL,
    CONSTRAINT [PK_TaFlujoTarea] PRIMARY KEY CLUSTERED ([IdFlujoTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

