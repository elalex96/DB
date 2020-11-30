CREATE TABLE [dbo].[CO_DirectorOperaciones] (
    [idDirector]     INT            IDENTITY (1000, 1) NOT NULL,
    [NombreCompleto] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK__CO_Direc__92E1D6EEFD122E83] PRIMARY KEY CLUSTERED ([idDirector] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

