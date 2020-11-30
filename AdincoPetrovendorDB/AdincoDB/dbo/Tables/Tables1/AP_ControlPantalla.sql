CREATE TABLE [dbo].[AP_ControlPantalla] (
    [IdControl]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombreControl] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AP_ControlPantalla] PRIMARY KEY CLUSTERED ([IdControl] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

