CREATE TABLE [dbo].[TC_TerminosYCondicionesDoc] (
    [IdTerminosYCondiciones] INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]            INT            NOT NULL,
    [Nombre]                 VARCHAR (MAX)  NULL,
    [Documento]              NVARCHAR (MAX) NULL,
    [Comentario]             VARCHAR (MAX)  NULL,
    [IsActivo]               BIT            NULL,
    CONSTRAINT [PK_TC_TerminosYCondicionesDoc] PRIMARY KEY CLUSTERED ([IdTerminosYCondiciones] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_TC_TerminosYCondicionesDoc_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

