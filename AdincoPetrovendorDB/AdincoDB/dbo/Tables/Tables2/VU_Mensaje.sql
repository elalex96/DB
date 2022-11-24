CREATE TABLE [dbo].[VU_Mensaje] (
    [IdMensaje]   INT            IDENTITY (1, 1) NOT NULL,
    [Mensaje]     NVARCHAR (MAX) NULL,
    [TipoMensaje] INT            NULL,
    [Mes]         DATE           NULL,
    [Activo]      BIT            CONSTRAINT [DF_Table_1_activo] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_VU_Mensaje] PRIMARY KEY CLUSTERED ([IdMensaje] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

