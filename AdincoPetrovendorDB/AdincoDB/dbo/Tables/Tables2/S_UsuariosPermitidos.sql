CREATE TABLE [dbo].[S_UsuariosPermitidos] (
    [idUAccept] INT            IDENTITY (1, 1) NOT NULL,
    [HostName]  NVARCHAR (MAX) NULL,
    [Browser]   NVARCHAR (MAX) NULL,
    [IsActive]  BIT            CONSTRAINT [DF__S_Usuario__IsAct__4C4DBFAC] DEFAULT ((0)) NULL,
    [UsuarioID] INT            NOT NULL,
    CONSTRAINT [PK__S_Usuari__CA65E1821659174B] PRIMARY KEY CLUSTERED ([idUAccept] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_UsuarioIDAcepted] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

