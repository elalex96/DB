CREATE TABLE [dbo].[AP_BitacoraDenegados] (
    [idUDeny]   INT            IDENTITY (1, 1) NOT NULL,
    [HostName]  NVARCHAR (MAX) NULL,
    [Browser]   NVARCHAR (MAX) NULL,
    [IsActive]  BIT            CONSTRAINT [DF__AP_Bitaco__IsAct__501E5090] DEFAULT ((0)) NULL,
    [UsuarioID] INT            NOT NULL,
    CONSTRAINT [PK__AP_Bitac__2AB2FBFA8E7CDA89] PRIMARY KEY CLUSTERED ([idUDeny] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_UsuarioIDDeny] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

