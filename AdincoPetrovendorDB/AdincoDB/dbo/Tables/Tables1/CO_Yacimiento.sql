CREATE TABLE [dbo].[CO_Yacimiento] (
    [IdYacimiento]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreYacimiento] NVARCHAR (MAX) NULL,
    [IdTipoYacimiento] INT            NULL,
    [GravedadAPI]      FLOAT (53)     NULL,
    [ProfundidadMedia] FLOAT (53)     NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_Yacimiento] PRIMARY KEY CLUSTERED ([IdYacimiento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

