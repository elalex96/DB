CREATE TABLE [dbo].[CO_Servicio] (
    [IdServicio]     INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]    INT            NULL,
    [NombreServicio] NVARCHAR (MAX) NULL,
    [IdUnidad]       INT            NULL,
    [IdUsuario]      INT            NULL,
    [FecMovto]       DATETIME       NULL,
    [Activo]         BIT            NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_Servicios] PRIMARY KEY CLUSTERED ([IdServicio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

