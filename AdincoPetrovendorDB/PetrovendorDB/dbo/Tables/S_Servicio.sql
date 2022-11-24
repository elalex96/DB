CREATE TABLE [dbo].[S_Servicio] (
    [IdServicio]  INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]      NVARCHAR (MAX) NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [IdProveedor] INT            NULL,
    [IsEliminado] BIT            NULL,
    CONSTRAINT [PK_S_Servicio] PRIMARY KEY CLUSTERED ([IdServicio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_Servici__IdPro__61F08603] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

